# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class AsyncRewriter < Base
      def on_block(node)
        recvr, args, body = node.children

        if recvr == s(:send, nil, :Async)
          body = rewrite_body(body)
          node.updated(:block, [recvr, args, body], location: node.loc)
        else
          super
        end
      end

      def rewrite_body(body)
        puts ">>>> rewrite Async do..."
        pp body
        if body && body.type == :begin
          original_body = body.to_a.clone
          rewriten_body = []
          while original_body.length > 0
            node = original_body.first
            original_body = original_body.slice(1..)
            rewriten_node, f = process_node(node, original_body)
            rewriten_body << rewriten_node
            break if f
          end

          s(:begin, *rewriten_body)
        else
          rewriten_body, f = process_node(body, nil)
          pp rewriten_body
          rewriten_body
        end
      end

      def process_node(node, original_body)
        puts ">>> process_node"
        if node.type == :block
          recvr, _, block = node.children
          if block.type == :begin
            block = s(:send, s(:block, s(:send, s(:const, nil, :Proc), :new), s(:args), block), :call)
          end
          if recvr == s(:send, nil, :await)
            if original_body
              rewriten = s(:block, s(:send, block, :then), s(:args), s(:begin, nil, *original_body))
            else
              rewriten = s(:send, block, :then)
            end
            return [rewriten, true]
          end
        end

        [node, false]
      end
    end
  end
end

p Opal::Rewriters::AsyncRewriter
