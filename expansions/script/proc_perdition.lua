EFFECT_CANNOT_BE_PERDITION_MATERIAL	=473
EFFECT_MUST_BE_PERDITION_MATERIAL		=474
EFFECT_EXTRA_PERDITION_MATERIAL		=475
TYPE_PERDITION						=0x2000000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_PERDITION
CTYPE_PERDITION						=0x20000
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_PERDITION

SUMMON_TYPE_PERDITION					=SUMMON_TYPE_SPECIAL+472

REASON_PERDITION						=0x400000000

--Custom Type Table
Auxiliary.Perditions={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_PERDITION_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_PERDITION

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Perditions[c] then
		tpe=tpe|TYPE_PERDITION
		if not Auxiliary.Perditions[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Perditions[c] then
		tpe=tpe|TYPE_PERDITION
		if not Auxiliary.Perditions[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Perditions[c] then
		tpe=tpe|TYPE_PERDITION
		if not Auxiliary.Perditions[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Perditions[rc] then
		rs=rs|REASON_PERDITION
	end
	return rs
end

function Auxiliary.AddOrigPerditionType(c,issynchro)
	table.insert(Auxiliary.Perditions,c)
	aux.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Perditions[c]=function() return issynchro end
end

function Auxiliary.PerditionExtraFilter(c,lc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_PERDITION_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBePerditionMaterial(lc) and (not flist or #flist<=0 or check)
end
function Auxiliary.PerditionRecursiveFilter(c,tp,sg,mg,bc,ct,...)
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
	local res=chk and (Auxiliary.PerditionCheckGoal(tp,sg,bc,ct,...)
		or (ct<max and mg:IsExists(Auxiliary.PerditionRecursiveFilter,1,sg,tp,sg,mg,bc,ct,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.PerditionCheckGoal(tp,sg,bc,ct,...)
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
		min=min+funs[i][2]
	end
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0
		and not sg:IsExists(function(c,mg,lc,p) return not Auxiliary.PerditionCheckOtherMaterial(c,mg-c,lc,p) end,1,nil,sg,bc,tp)
end

function Auxiliary.PerditionCheckOtherMaterial(c,mg,lc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_PERDITION_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,lc,mg) then return false end
	end
	return true
end

function Auxiliary.AddPerditionProc(c,...)
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
		end
		if #t<2 then break end
	end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.PerditionCondition(table.unpack(list)))
	ge2:SetTarget(Auxiliary.PerditionTarget(table.unpack(list)))
	ge2:SetOperation(Auxiliary.PerditionOperation)
	ge2:SetValue(SUMMON_TYPE_PERDITION)
	c:RegisterEffect(ge2)
end

function Auxiliary.PerditionCondition(...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBePerditionMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.PerditionExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_PERDITION_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return mg:IsExists(Auxiliary.PerditionRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,c,0,table.unpack(funs))
			end
end

function Auxiliary.PerditionTarget(...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBePerditionMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.PerditionExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_PERDITION_MATERIAL)}
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
					finish=Auxiliary.PerditionCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.PerditionRecursiveFilter,sg,tp,sg,mg,c,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
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
function Auxiliary.PerditionOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	for tc in aux.Next(g) do
		if c:IsHasEffect(EFFECT_EXTRA_PERDITION_MATERIAL) then
			local tef={tc:IsHasEffect(EFFECT_EXTRA_PERDITION_MATERIAL)}
			for _,te in ipairs(tef) do
				local op=te:GetOperation()
				if op then
					op(tc,tp)
				else
					Duel.Remove(tc,POS_FACEUP,REASON_MATERIAL+REASON_PERDITION)
				end
			end
		else
			Duel.Remove(tc,POS_FACEUP,REASON_MATERIAL+REASON_PERDITION)
		end
	end
	g:DeleteGroup()
end
