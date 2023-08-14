function RunC()
  local filename = vim.fn.expand('%')
  filename = "\"" .. filename .. "\""


  local output_buffer = 1
  local output_window = vim.fn.bufwinnr(output_buffer)

  -- Save the current buffer if it has changes
  if vim.bo.modified then
    vim.cmd('silent! write')
  end

  local run_cmd = 'g++-13 -std=c++0x -DLOCAL ' .. filename .. ' -o out && ./out && rm out'
  local run_output = vim.fn.systemlist(run_cmd)

  -- Open a new buffer to display the run output
  if output_window > 0 then
    vim.cmd(output_window .. 'wincmd w')
    vim.cmd('silent! bwipeout!')
  end
  vim.cmd('vnew ' .. output_buffer)
  vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(0, 'swapfile', false)
  vim.fn.append(0, run_output)
end
