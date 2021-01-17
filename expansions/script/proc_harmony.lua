--coded by Lyris
--調波召喚
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_HARMONIZED_MATERIAL=531
EFFECT_MUST_BE_HARMONIZED_MATERIAL	=532
EFFECT_EXTRA_HARMONIZED_MATERIAL	=533
TYPE_HARMONY						=0x80000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_HARMONY
CTYPE_HARMONY						=0x800
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_HARMONY
SUMMON_TYPE_HARMONY					=SUMMON_TYPE_SPECIAL+531

REASON_HARMONY						=0x2000000000

--Custom Type Table
Auxiliary.Harmonies={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_HARMONIZED_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_HARMONY

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Harmonies[rc] then
		rs=rs|REASON_HARMONY
	end
	return rs
end

--Custom Functions
function Card.IsCanBeHarmonizedMaterial(c,sptc)
	if c:IsOnField() and not c:IsFaceup() or (c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup()) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_HARMONIZED_MATERIAL)}
	for _,te in ipairs(tef) do
		if (type(te:GetValue())=="function" and te:GetValue()(te,spct)) or te:GetValue()==1 then return false end
	end
	return true
end
function Auxiliary.AddOrigHarmonyType(c,issynchro)
	table.insert(Auxiliary.Harmonies,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Harmonies[c]=function() return issynchro end
end
function Auxiliary.AddHarmonyProc(c,ph,...)
	--ph - Phase to be used as Harmonized Material
	--... format - any number of materials  use aux.TRUE for generic materials
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local list={}
	local min,max
	for i=1,#t do
		if type(t[#t])=='number' then
			max=t[#t]
			table.remove(t)
			if type(t[#t])=='number' then
				min=t[#t]
				table.remove(t)
			else
				min=max
				max=99
			end
			table.insert(list,{t[#t],min,max})
			table.remove(t)
		elseif type(t[#t])=='function' then
			table.insert(list,{t[#t],1,1})
			table.remove(t)
		end
		if #t<2 then break end
	end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.HarmonyCondition(table.unpack(list)))
	ge2:SetTarget(Auxiliary.HarmonyTarget(table.unpack(list)))
	ge2:SetOperation(Auxiliary.HarmonyOperation(ph))
	ge2:SetValue(531)
	c:RegisterEffect(ge2)
	local ge5=Effect.CreateEffect(c)
	ge5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
	ge5:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge5:SetCountLimit(1)
	ge5:SetRange(0xff)
	ge5:SetOperation(Auxiliary.HCheckReg)
	c:RegisterEffect(ge5)
end
function Auxiliary.HCheckRecursive(c,tp,sg,mg,sptc,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},0
	for i=1,#funs do
		max=max+funs[i][3]
		if funs[i][1](c) then
			chk=true
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.HCheckGoal(tp,sg,sptc,ct,...)
		or (ct<max and mg:IsExists(Auxiliary.HCheckRecursive,1,sg,tp,sg,mg,sptc,ct,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.HCheckGoal(tp,sg,Hc,ct,...)
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
		min=min+funs[i][2]
	end
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,Hc)>0
		and not sg:IsExists(Auxiliary.HarmonizedUncompatibilityFilter,1,nil,sg,Hc,tp)
end
function Auxiliary.HarmonizedUncompatibilityFilter(c,sg,spct,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.HarmonizedCheckOtherMaterial(c,mg,spct,tp)
end
function Auxiliary.HarmonizedCheckOtherMaterial(c,mg,spct,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,spct,mg) then return false end
	end
	return true
end
function Auxiliary.HarmonizedExtraFilter(c,lc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeHarmonizedMaterial(lc) and (not flist or #flist<=0 or check)
end
function Auxiliary.HarmonyCondition(...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeHarmonizedMaterial,tp,LOCATION_REMOVED,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.HarmonizedExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_HARMONIZED_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				local sg=Group.CreateGroup()
				return mg:IsExists(Auxiliary.HCheckRecursive,1,sg,tp,sg,mg,c,table.unpack(funs))
			end
end
function Auxiliary.HarmonyTarget(...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeHarmonizedMaterial,tp,LOCATION_REMOVED,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.HarmonizedExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_HARMONIZED_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while not (#sg>=max) do
					finish=Auxiliary.HCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.HCheckRecursive,sg,tp,sg,mg,c,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if (#sg>=max) then finish=true end
						else
							sg:RemoveCard(tc)
						end
					elseif #bg>0 and #sg<=#bg then
						return false
					end
				end
				if finish then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.HarmonyOperation(ph)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				for tc in aux.Next(g) do
					if c:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL) then
						local tef={tc:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL)}
						for _,te in ipairs(tef) do
							local op=te:GetOperation()
							if op then
								op(tc,tp)
							else
								Duel.SendtoDeck(tc,nil,2,REASON_MATERIAL+REASON_HARMONY)
							end
						end
					else
						Duel.SendtoDeck(tc,nil,2,REASON_MATERIAL+REASON_HARMONY)
					end
				end
				g:DeleteGroup()
				local p
				for i=0,9 do
					p=ph&1<<i
					if p>0 then
						Duel.SkipPhase(tp,p,RESET_PHASE+p,1)
					end
					ph=ph&~1<<i
					if ph==0 then break end
				end
			end
end
function Auxiliary.HCards(c)
	if not Auxiliary.Harmonies[c] then return false end
	if c:IsLocation(LOCATION_GRAVE) then return true end
	if c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	return c:IsFaceup() or c:IsLocation(LOCATION_EXTRA)
end
function Auxiliary.HCheckReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=1-c:GetOwner()
	local g=Duel.GetMatchingGroup(Auxiliary.HCards,p,0x70,0,nil)
	if #g==0 then
		local ge7=Effect.CreateEffect(c)
		ge7:SetType(EFFECT_TYPE_SINGLE)
		ge7:SetRange(LOCATION_MZONE)
		ge7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		ge7:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
		c:RegisterEffect(ge7)
	end
	local ge8=Effect.CreateEffect(c)
	ge8:SetType(EFFECT_TYPE_SINGLE)
	ge8:SetCode(EFFECT_SPSUMMON_COST)
	ge8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ge8:SetCost(Auxiliary.HCheck)
	ge8:SetOperation(Auxiliary.HCheckOp)
	c:RegisterEffect(ge8)
	local ge9=ge8:Clone()
	ge9:SetCode(EFFECT_FLIPSUMMON_COST)
	c:RegisterEffect(ge9)
end
function Auxiliary.HCheck(e,c,tp)
	local p=e:GetHandler():GetOwner()
	return p~=tp and Duel.IsExistingMachingCard(Auxiliary.HCards,tp,0x70,0,1,nil)
end
function Auxiliary.HCheckOp(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	if not Duel.IsExistingMachingCard(Auxiliary.HCards,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) then
		Duel.ConfirmCards(1-p,Duel.GetFirstMachingCard(Auxiliary.HCards,p,LOCATION_EXTRA,0,nil))
	end
end
