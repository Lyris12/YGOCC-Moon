--Code for some anime only xyz summon mechanics. Load with "xpcall(function() require("expansions/script/c115000000") end,function() require("script/c115000000") end)"
--Original script by ygo pro vs links, adaptations to koishpro by somen00b
--	--Example effect 1: Treat the card with this effect as 2 materials
--	local e1=Effect.CreateEffect(c)
--	e1:SetType(EFFECT_TYPE_SINGLE)
--	e1:SetCode(511001225)
--	e1:SetOperation(c249000000.tgval)
--	e1:SetValue(1) -- the '1' is the number of additional materials the monster counts as, setting it to 2 would make the monster treated as 1 or 3 materials ect
--	c:RegisterEffect(e1)
--function c249000000.tgval(e,c)
--	return c:IsSetCard(0x107F) -- this is the condition that needs to be met for the card to count as multiple materials, in this case it has to be used to summon a Utopia monster
--end
--If you wanted the card to be treated as up to 3 materials you'd need to register 2 versions of this effect, 1 with the value '1' and 1 with the value '2'
-- Example effect 2: This card can be used as an xyz material while in your hand
--  local e1=Effect.CreateEffect(c)
--	e:SetType(EFFECT_TYPE_SINGLE)
--	e:SetCode(511002793)
--	e1:SetRange(LOCATION_HAND) --this is the location where the card can be used as a material in addition to the monster zone.
--	c:RegisterEffect(e1)

function Auxiliary.XyzAlterFilter(c,alterf,xyzc,e,tp,op)
	if not alterf(c) or not c:IsCanBeXyzMaterial(xyzc) or (c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_XYZ_MATERIAL)) 
		or (op and not op(e,tp,0,c)) then return false end
	if xyzc:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,c,xyzc)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:GetSequence()<5
	end
end
--Xyz monster, lv k*n
function Auxiliary.AddXyzProcedure(c,f,lv,ct,alterf,desc,maxct,op,mustbemat,exchk)
	--exchk for special xyz, checking other materials
	--mustbemat for Startime Magician
	if not maxct then maxct=ct end	
	if c.xyz_filter==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.xyz_filter=function(mc,ignoretoken) return mc and (not f or f(mc)) and mc:IsXyzLevel(c,lv) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.xyz_parameters={mt.xyz_filter,lv,ct,alterf,desc,maxct,op,mustbemat,exchk}
		mt.minxyzct=ct
		mt.maxxyzct=maxct
	end
	
	local chk1=Effect.CreateEffect(c)
	chk1:SetType(EFFECT_TYPE_SINGLE)
	chk1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	chk1:SetCode(946)
	chk1:SetCondition(Auxiliary.XyzCondition(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetTarget(Auxiliary.XyzTarget(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetOperation(Auxiliary.XyzOperation(f,lv,ct,maxct,mustbemat,exchk))
	c:RegisterEffect(chk1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1073)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.XyzCondition(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetTarget(Auxiliary.XyzTarget(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetOperation(Auxiliary.XyzOperation(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	if alterf then
		local chk2=chk1:Clone()
		chk2:SetDescription(desc)
		chk2:SetCondition(Auxiliary.XyzCondition2(alterf,op))
		chk2:SetTarget(Auxiliary.XyzTarget2(alterf,op))
		chk2:SetOperation(Auxiliary.XyzOperation2(alterf,op))
		c:RegisterEffect(chk2)
		local e2=e1:Clone()
		e2:SetDescription(desc)
		e2:SetCondition(Auxiliary.XyzCondition2(alterf,op))
		e2:SetTarget(Auxiliary.XyzTarget2(alterf,op))
		e2:SetOperation(Auxiliary.XyzOperation2(alterf,op))
		c:RegisterEffect(e2)
	end
	
	if not xyztemp then
		xyztemp=true
		xyztempg0=Group.CreateGroup()
		xyztempg0:KeepAlive()
		xyztempg1=Group.CreateGroup()
		xyztempg1:KeepAlive()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		e3:SetCode(EVENT_ADJUST)
		e3:SetCountLimit(1)
		e3:SetOperation(Auxiliary.XyzMatGenerate)
		Duel.RegisterEffect(e3,0)
	end
end
function Auxiliary.XyzMatGenerate(e,tp,eg,ep,ev,re,r,rp)
	local tck0=Duel.CreateToken(0,86871615)
	xyztempg0:AddCard(tck0)
	local tck1=Duel.CreateToken(1,86871615)
	xyztempg1:AddCard(tck1)
end
--Xyz Summon(normal)
function Auxiliary.XyzMatFilter2(c,f,lv,xyz,tp)
	local te=nil
	if not global_card_effect_table[c] then return false end
	for key,value in pairs(global_card_effect_table[c]) do
		if value and value:GetCode()==511002793
			then te=value
		end
	end
	if not c:IsLocation(LOCATION_MZONE) and (te==nil or not c:IsLocation(te:GetRange())) then return false end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return false end
	return Auxiliary.XyzMatFilter(c,f,lv,xyz,tp)
end
function Auxiliary.XyzMatFilter(c,f,lv,xyz,tp)
	return (not f or f(c)) and (not lv or c:IsXyzLevel(xyz,lv)) and c:IsCanBeXyzMaterial(xyz) 
		and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL))
end
function Auxiliary.XyzSubMatFilter(c,fil,lv,xg)
	if not lv then return false end
	--Solid Overlay-type
	local te=nil
	if not global_card_effect_table[c] then return false end
	for key,value in pairs(global_card_effect_table[c]) do
		if value and value:GetCode()==511000189
			then te=value
		end
	end
	--local te=c:GetCardEffect(511000189)
	if not te then return false end
	local f=te:GetValue()
	if type(f)=='function' then
		if f(te)~=lv then return false end
	else
		if f~=lv then return false end
	end
	return xg:IsExists(Auxiliary.XyzSubFilterChk,1,nil,fil)
end
function Auxiliary.XyzSubFilterChk(c,f)
	return (not f or f(c))
end
function Auxiliary.CheckValidMultiXyzMaterial(c,xyz)
	if not c:IsHasEffect(511001225) then return false end
	local eff={}
	for key,value in pairs(global_card_effect_table[c]) do
		if value and value:GetCode()==511001225 then
			table.insert(eff,value)
		end
	end
	--local eff={c:GetCardEffect(511001225)}
	for i=1,#eff do
		local te=eff[i]
		local tgf=te:GetOperation()
		if not tgf or tgf(te,xyz) then return true end
	end
	return false
end
function Auxiliary.XyzRecursionChk1(c,mg,xyz,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f)
	local xct=ct
	local rg=Group.CreateGroup()
	if not c:IsHasEffect(511002116) then
		xct=xct+1
	end
	local xmatct=matct+1
	--local eff={c:GetCardEffect(73941492+TYPE_XYZ)}
	local eff={}
	for key,value in pairs(global_card_effect_table[c]) do
		if value and value:GetCode()==73941492+TYPE_XYZ then
			table.insert(eff,value)
		end
	end
	for i,f in ipairs(eff) do
		if matg:IsExists(Auxiliary.TuneMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(function(c) return not Auxiliary.TuneMagFilterFus(c,f,f:GetValue()) end,nil)
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	local g2=matg:Filter(Card.IsHasEffect,nil,73941492+TYPE_XYZ)
	if g2:GetCount()>0 then
		local tc=g2:GetFirst()
		while tc do
			--local eff={tc:GetCardEffect(73941492+TYPE_XYZ)}
			local eff={}
			for key,value in pairs(global_card_effect_table[tc]) do
				if value and value:GetCode()==73941492+TYPE_XYZ then
					table.insert(eff,value)
				end
			end
			for i,f in ipairs(eff) do
				if Auxiliary.TuneMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=g2:GetNext()
		end	
	end
	if xct>max or xmatct>maxc then mg:Merge(rg) return false end
	if not c:IsHasEffect(511002116) then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local res=nil
	if xct>=min and xmatct>=minc then
		local ok=true
		if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
			ok=Auxiliary.MatNumChkF(matg)
		end
		if exchk then
			if matg:GetCount()>0 and not matg:IsExists(f,matg:GetCount(),nil,true,tp,matg) then ok=false end
		end
		if ok then
			if xyz:IsLocation(LOCATION_EXTRA) then
				if Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0 then res=true end
			else
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or matg:IsExists(Auxiliary.FieldChk,1,nil,tp) then res=true end
			end
		end
	end
	local retchknum={0}
	local retchk={mg:IsExists(Auxiliary.XyzRecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct,mustbemat,exchk,f)}
	if not res and c:IsHasEffect(511001225) and not mustbemat then
		local eff={}
		for key,value in pairs(global_card_effect_table[c]) do
			if value and value:GetCode()==511001225 then
				table.insert(eff,value)
			end
		end
		--local eff={c:GetCardEffect(511001225)}
		for i,te in ipairs(eff) do
			local tgf=te:GetOperation()
			local val=te:GetValue()
			local redun=false
			for _,v in ipairs(retchknum) do
				if v==val then redun=true break end
			end	
			if not redun and val>0 and (not tgf or tgf(te,xyz)) then
				if xct>=min and xmatct+val>=minc and xct<=max and xmatct+val<=maxc then
					local ok=true
					if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
						ok=Auxiliary.MatNumChkF(matg)
					end
					if exchk then
						if matg:GetCount()>0 and not matg:IsExists(f,matg:GetCount(),nil,true,tp,matg) then ok=false end
					end
					if ok then
						if xyz:IsLocation(LOCATION_EXTRA) then
							if Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0 then res=true end
						else
							if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or matg:IsExists(Auxiliary.FieldChk,1,nil,tp) then res=true end
						end
					end
				end
				if xmatct+val<=maxc then
					table.insert(retchknum,val)
					table.insert(retchk,mg:IsExists(Auxiliary.XyzRecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct+val,mustbemat,exchk,f))
				end
			end
		end
	end
	for i=1,#retchk do
		if retchk[i] then res=true break end
	end
	matg:RemoveCard(c)
	sg:RemoveCard(c)
	mg:Merge(rg)
	return res
end
function Auxiliary.XyzRecursionChk2(c,mg,xyz,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f)
	local rg=Group.CreateGroup()
	if c:IsHasEffect(511001175) and not sg:IsContains(c:GetEquipTarget()) then return false end
	local xct=ct+1
	local eff={}
	if global_card_effect_table[c] then
		for key,value in pairs(global_card_effect_table[c]) do
			if value and value:GetCode()==73941492+TYPE_XYZ then
				table.insert(eff,value)
			end
		end
	end
	--local eff={c:GetCardEffect(73941492+TYPE_XYZ)}
	for i,f in ipairs(eff) do
		if matg:IsExists(Auxiliary.TuneMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(function(c) return not Auxiliary.TuneMagFilterFus(c,f,f:GetValue()) end,nil)
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	local g2=sg:Filter(Card.IsHasEffect,nil,73941492+TYPE_XYZ)
	if g2:GetCount()>0 then
		local tc=g2:GetFirst()
		while tc do
			local eff={}
			for key,value in pairs(global_card_effect_table[tc]) do
				if value and value:GetCode()==73941492+TYPE_XYZ then
					table.insert(eff,value)
				end
			end
			--local eff={tc:GetCardEffect(73941492+TYPE_XYZ)}
			for i,f in ipairs(eff) do
				if Auxiliary.TuneMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=g2:GetNext()
		end
	end
	if xct>maxc then mg:Merge(rg) return false end
	if not c:IsHasEffect(511001175) and not c:IsHasEffect(511002116) then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local res=nil
	if xct>=minc then
		local ok=true
		if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
			ok=Auxiliary.MatNumChkF(matg)
		end
		if exchk then
			if matg:GetCount()>0 and not matg:IsExists(f,matg:GetCount(),nil,true,tp,matg) then ok=false end
		end
		if ok then
			if xyz:IsLocation(LOCATION_EXTRA) then
				if Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0 then res=true end
			else
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or matg:IsExists(Auxiliary.FieldChk,1,nil,tp) then res=true end
			end
		end
	end
	local eqg=Group.CreateGroup()
	if not mustbemat then
		eqg:Merge(c:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
		mg:Merge(eqg)
	end
	local retchknum={0}
	local retchk={mg:IsExists(Auxiliary.XyzRecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct,mustbemat,exchk,f)}
	if not res and c:IsHasEffect(511001225) and not mustbemat then
		local eff={}
		for key,value in pairs(global_card_effect_table[c]) do
			if value and value:GetCode()==511001225 then
				table.insert(eff,value)
			end
		end
		--local eff={c:GetCardEffect(511001225)}
		for i,te in ipairs(eff) do
			local tgf=te:GetOperation()
			local val=te:GetValue()
			local redun=false
			for _,v in ipairs(retchknum) do
				if v==val then redun=true break end
			end
			if val>0 and (not tgf or tgf(te,xyz)) and not redun then
				if xct+val>=minc and xct+val<=maxc then
					local ok=true
					if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
						ok=Auxiliary.MatNumChkF(matg)
					end
					if exchk then
						if matg:GetCount()>0 and not matg:IsExists(f,matg:GetCount(),nil,true,tp,matg) then ok=false end
					end
					if ok then
						if xyz:IsLocation(LOCATION_EXTRA) then
							if Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0 then res=true end
						else
							if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or matg:IsExists(Auxiliary.FieldChk,1,nil,tp) then res=true end
						end
					end
				end
				if xct+val<=maxc then
					retchknum[#retchknum+1]=val
					retchk[#retchk+1]=mg:IsExists(Auxiliary.XyzRecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct+val,mustbemat,exchk,f)
				end
			end
		end
	end
	for i=1,#retchk do
		if retchk[i] then res=true break end
	end
	matg:RemoveCard(c)
	sg:RemoveCard(c)
	mg:Sub(eqg)
	mg:Merge(rg)
	return res
end
function Auxiliary.MatNumChkF(tg)
	local chkg=tg:Filter(Card.IsHasEffect,nil,91110378)
	for chkc in aux.Next(chkg) do
		local eff={}
		for key,value in pairs(global_card_effect_table[c]) do
			if value and value:GetCode()==91110378 then
				table.insert(eff,value)
			end
		end
		--local eff={chkc:GetCardEffect(91110378)}
		for j=1,#eff do
			local rct=eff[j]:GetValue()
			local comp=eff[j]:GetLabel()
			if not Auxiliary.MatNumChk(tg:FilterCount(Card.IsType,nil,TYPE_MONSTER),rct,comp) then return false end
		end
	end
	return true
end
function Auxiliary.MatNumChk(matct,ct,comp)
	local ok=false
	if not ok and bit.band(comp,0x1)==0x1 and matct>ct then ok=true end
	if not ok and bit.band(comp,0x2)==0x2 and matct==ct then ok=true end
	if not ok and bit.band(comp,0x4)==0x4 and matct<ct then ok=true end
	return ok
end
function Auxiliary.TuneMagFilter(c,e,f)
	return f and not f(e,c)
end
function Auxiliary.TuneMagFilterXyz(c,e,f)
	return not f or f(e,c) or c:IsHasEffect(511002116) or c:IsHasEffect(511001175)
end
function Auxiliary.XyzCondition(f,lv,minc,maxc,mustbemat,exchk)
	--og: use special material
	return	function(e,c,og,min,max)
				if c==nil then return true end
				local tp=c:GetControler()
				local xg=nil
				if tp==0 then
					xg=xyztempg0
				else
					xg=xyztempg1
				end
				if not xg or xg:GetCount()==0 then return false end
				local mg
				if og then
					mg=og:Filter(Auxiliary.XyzMatFilter,nil,f,lv,c,tp)
				else
					mg=Duel.GetMatchingGroup(Auxiliary.XyzMatFilter2,tp,0xFF,LOCATION_MZONE,nil,f,lv,c,tp)
					if not mustbemat then
						local eqmg=Group.CreateGroup()
						for tc in aux.Next(mg) do
							local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
							eqmg:Merge(eq)
						end
						mg:Merge(eqmg)
						mg:Merge(Duel.GetMatchingGroup(Auxiliary.XyzSubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,xg))
					end
				end
				if not mustbemat then
					mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
				end
				if min and min~=99 then
					return mg:IsExists(Auxiliary.XyzRecursionChk1,1,nil,mg,c,tp,min,max,minc,maxc,Group.CreateGroup(),Group.CreateGroup(),0,0,mustbemat,exchk,f)
				else
					return mg:IsExists(Auxiliary.XyzRecursionChk2,1,nil,mg,c,tp,minc,maxc,Group.CreateGroup(),Group.CreateGroup(),0,mustbemat,exchk,f)
				end
				return false
			end
end
function Auxiliary.FieldChk(c,tp)
	return c:GetSequence()<5 and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function Auxiliary.XyzTarget(f,lv,minc,maxc,mustbemat,exchk)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if og and not min then
					if (og:GetCount()>=minc and og:GetCount()<=maxc) or not og:IsExists(Card.IsHasEffect,1,nil,511002116) then
						og:KeepAlive()
						e:SetLabelObject(og)
						return true
					else
						local tab={}
						local ct,matct,min,max=0,0,og:GetCount(),og:GetCount()
						local matg=Group.CreateGroup()
						local sg=Group.CreateGroup()
						local mg=og:Clone()
						mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
						local cancel=false
						while ct<max and matct<maxc do
							local selg=mg:Filter(Auxiliary.XyzRecursionChk1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f)
							if selg:GetCount()<=0 then break end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local sc=Group.SelectUnselect(selg,sg,tp,cancel,cancel)
							if not sc then break end
							if ct>=min and matct>=maxc then cancel=true end
							if not sg:IsContains(sc) then
								sg:AddCard(sc)
								if sc:IsHasEffect(511002116) then
									matct=matct+1
								elseif sc:IsHasEffect(511001225) then
									matg:AddCard(sc)
									ct=ct+1
									if not Auxiliary.CheckValidMultiXyzMaterial(sc,c) or (min>=ct and minc>=matct+1) then
										matct=matct+1
									else
										local multi={}
										if mg:IsExists(Auxiliary.XyzRecursionChk1,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct+1,mustbemat,exchk,f) then
											table.insert(multi,1)
										end
										local eff={}
										for key,value in pairs(global_card_effect_table[sc]) do
											if value and value:GetCode()==511001225 then
												table.insert(eff,value)
											end
										end
										--local eff={sc:GetCardEffect(511001225)}
										for i=1,#eff do
											local te=eff[i]
											local tgf=te:GetOperation()
											local val=te:GetValue()
											if val>0 and (not tgf or tgf(te,c)) then
												if (min>=ct and minc>=matct+1+val) 
													or mg:IsExists(Auxiliary.XyzRecursionChk1,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct+1+val,mustbemat,exchk,f) then
													table.insert(multi,1+val)
												end
											end
										end
										if #multi==1 then
											tab[sc]=multi[1]
											matct=matct+multi[1]
										else
											Duel.Hint(HINT_SELECTMSG,tp,513)
											local num=Duel.AnnounceNumber(tp,table.unpack(multi))
											tab[sc]=num
											matct=matct+num
										end
									end
								else
									matg:AddCard(sc)
									ct=ct+1
									matct=matct+1
								end
							else
								sg:RemoveCard(sc)
								if sc:IsHasEffect(511002116) then
									matct=matct-1
								else
									matg:RemoveCard(sc)
									ct=ct-1
									local num=tab[sc]
									if num then
										tab[sc]=nil
										matct=matct-num
									else
										matct=matct-1
									end
								end
							end
						end
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					end
					--end of part 1
				else
					local cancel=not og and Duel.GetCurrentChain()<=0
					local xg=nil
					if tp==0 then
						xg=xyztempg0
					else
						xg=xyztempg1
					end
					local mg
					if og then
						mg=og:Filter(Auxiliary.XyzMatFilter,nil,f,lv,c,tp)
					else
						mg=Duel.GetMatchingGroup(Auxiliary.XyzMatFilter2,tp,0xFF,LOCATION_MZONE,nil,f,lv,c,tp)
						if not mustbemat then
							local eqmg=Group.CreateGroup()
							for tc in aux.Next(mg) do
								local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
								eqmg:Merge(eq)
							end
							mg:Merge(eqmg)
							mg:Merge(Duel.GetMatchingGroup(Auxiliary.XyzSubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,xg))
						end
					end
					if not mustbemat then
						mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
					end
					if not og or min==99 then
						local ct=0
						local matg=Group.CreateGroup()
						local sg=Group.CreateGroup()
						local tab={}
						while ct<maxc do
							local tg=mg:Filter(Auxiliary.XyzRecursionChk2,sg,mg,c,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f)
							if tg:GetCount()==0 then break end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local sc=Group.SelectUnselect(tg,sg,tp,cancel,cancel)
							if not sc then
								if matg:GetCount()<minc 
									or (matg:IsExists(Card.IsHasEffect,1,nil,91110378) and not Auxiliary.MatNumChkF(matg)) then return false end
								if c:IsLocation(LOCATION_EXTRA) then
									if Duel.GetLocationCountFromEx(tp,tp,matg,c)<=0 then return false end
								else
									if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and not matg:IsExists(Auxiliary.FieldChk,1,nil,tp) then return false end
								end
								break
							end
							if not sg:IsContains(sc) then
								sg:AddCard(sc)
								mg:Merge(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
								if not sc:IsHasEffect(511002116) then
									matg:AddCard(sc)
								end
								ct=ct+1
								if Auxiliary.CheckValidMultiXyzMaterial(sc,c) and ct<minc then
									local multi={}
									if mg:IsExists(Auxiliary.XyzRecursionChk2,1,sg,mg,c,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f) then
										table.insert(multi,1)
									end
									--local eff={sc:GetCardEffect(511001225)}
									local eff={}
									for key,value in pairs(global_card_effect_table[sc]) do
										if value and value:GetCode()==511001225 then
											table.insert(eff,value)
										end
									end
									for i=1,#eff do
										local te=eff[i]
										local tgf=te:GetOperation()
										local val=te:GetValue()
										if val>0 and (not tgf or tgf(te,c)) then
											if minc>=ct+val 
												or mg:IsExists(Auxiliary.XyzRecursionChk2,1,sg,mg,c,tp,minc,maxc,sg,matg,ct+val,mustbemat,exchk,f) then
												table.insert(multi,1+val)
											end
										end
									end
									if #multi==1 then
										if multi[1]>1 then
											ct=ct+multi[1]-1
											tab[sc]=multi[1]
										end
									else
										Duel.Hint(HINT_SELECTMSG,tp,513)
										local num=Duel.AnnounceNumber(tp,table.unpack(multi))
										if num>1 then
											ct=ct+num-1
											tab[sc]=num
										end
									end
								end
							else
								sg:RemoveCard(sc)
								mg:Sub(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
								if not sc:IsHasEffect(511002116) then
									matg:RemoveCard(sc)
								end
								ct=ct-1
								if tab[sc] then
									ct=ct-tab[sc]+1
									tab[sc]=nil
								end
							end
							if ct>=minc and (not matg:IsExists(Card.IsHasEffect,1,nil,91110378) or Auxiliary.MatNumChkF(matg)) then
								cancel=true
							else
								cancel=not og and Duel.GetCurrentChain()<=0 and sg:GetCount()==0
							end
						end
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					end
					return false
				end
			end
end
function Auxiliary.XyzOperation(f,lv,minc,maxc,mustbemat,exchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				local g=e:GetLabelObject()
				if not g then return end
				local remg=g:Filter(Card.IsHasEffect,nil,511002116)
				remg:ForEach(function(c) c:RegisterFlagEffect(511002115,RESET_EVENT+0x1fe0000,0,0) end)
				g:Remove(Card.IsHasEffect,nil,511002116)
				g:Remove(Card.IsHasEffect,nil,511002115)
				local sg=Group.CreateGroup()
				for tc in aux.Next(g) do
					local sg1=tc:GetOverlayGroup()
					sg:Merge(sg1)
				end
				Duel.SendtoGrave(sg,REASON_RULE)
				c:SetMaterial(g)
				Duel.Overlay(c,g:Filter(function(c) return c:GetEquipTarget() end,nil))
				Duel.Overlay(c,g)
				g:DeleteGroup()
			end
end
--Xyz summon(alterf)
function Auxiliary.XyzCondition2(alterf,op)
	return	function(e,c,og,min,max)
				if c==nil then return true end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
				end
				return (not min or min<=1) and mg:IsExists(Auxiliary.XyzAlterFilter,1,nil,alterf,c,e,tp,op)
			end
end
function Auxiliary.XyzTarget2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if og and not min then
					return true
				end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
				end
				local b1=Duel.CheckXyzMaterial(c,f,lv,minc,maxc,og)
				local b2=(not min or min<=1) and mg:IsExists(Auxiliary.XyzAlterFilter,1,nil,alterf,c,e,tp,op)
				local g=nil
				if b2 and (not b1 or Duel.SelectYesNo(tp,desc)) then
					e:SetLabel(1)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					g=mg:FilterSelect(tp,Auxiliary.XyzAlterFilter,1,1,nil,alterf,c,e,tp,op)
					if op then op(e,tp,1,g:GetFirst()) end
				else
					e:SetLabel(0)
					g=Duel.SelectXyzMaterial(tp,c,f,lv,minc,maxc,og)
				end
				if g then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end	
function Auxiliary.XyzOperation2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				if og and not min then
					local sg=Group.CreateGroup()
					local tc=og:GetFirst()
					while tc do
						local sg1=tc:GetOverlayGroup()
						sg:Merge(sg1)
						tc=og:GetNext()
					end
					Duel.SendtoGrave(sg,REASON_RULE)
					c:SetMaterial(og)
					Duel.Overlay(c,og)
				else
					local mg=e:GetLabelObject()
					if e:GetLabel()==1 then
						local mg2=mg:GetFirst():GetOverlayGroup()
						if mg2:GetCount()~=0 then
							Duel.Overlay(c,mg2)
						end
					else
						local sg=Group.CreateGroup()
						local tc=mg:GetFirst()
						while tc do
							local sg1=tc:GetOverlayGroup()
							sg:Merge(sg1)
							tc=mg:GetNext()
						end
						Duel.SendtoGrave(sg,REASON_RULE)
					end
					c:SetMaterial(mg)
					Duel.Overlay(c,mg)
					mg:DeleteGroup()
				end
			end
end
