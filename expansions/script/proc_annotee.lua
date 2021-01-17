--coded by Lyris
--付注召喚
EFFECT_INHERITOR					=748
EFFECT_CANNOT_BE_ANNOTEE_MATERIAL	=749
EFFECT_MUST_BE_ANNOTEE_MATERIAL		=750
TYPE_ANNOTEE						=0x800000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_ANNOTEE
CTYPE_ANNOTEE						=0x8000
CTYPE_CUSTOM						=CTYPE_CUSTOM|TYPE_ANNOTEE

REASON_ANNOTEE						=0x800000000

--Custom Type Table
Auxiliary.Annotees={} --number as index = card, card as index = function() is_ritual

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Annotees[c] then
		tpe=tpe|TYPE_ANNOTEE
		if not Auxiliary.Annotees[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Annotees[c] then
		tpe=tpe|TYPE_ANNOTEE
		if not Auxiliary.Annotees[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Annotees[c] then
		tpe=tpe|TYPE_ANNOTEE
		if not Auxiliary.Annotees[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Annotees[rc] then
		rs=rs|REASON_ANNOTEE
	end
	return rs
end

--Custom Functions
function Card.IsCanBeAnnoteeMaterial(c,ac)
	if c:IsLevelBelow(0) or c:IsStatus(STATUS_NO_LEVEL) or c:IsFacedown() then return false end
	local tef2={c:IsHasEffect(EFFECT_CANNOT_BE_ANNOTEE_MATERIAL)}
	for _,te2 in ipairs(tef2) do
		if te2:GetValue()(te2,ac) then return false end
	end
	return true
end
function Auxiliary.AddOrigAnnoteeType(c,isritual)
	table.insert(Auxiliary.Annotees,c)
	Auxiliary.Customs[c]=true
	local isritual=isritual==nil and false or isritual
	Auxiliary.Annotees[c]=function() return isritual end
end
function Auxiliary.AddAnnoteeProc(c,minc,maxc,alterf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	ge2:SetRange(LOCATION_HAND)
	ge2:SetCondition(Auxiliary.AnnoteeCondition(minc,maxc,alterf,...))
	ge2:SetTarget(Auxiliary.AnnoteeTarget(minc,maxc,alterf,...))
	ge2:SetOperation(Auxiliary.AnnoteeOperation)
	ge2:SetValue(0x2a)
	c:RegisterEffect(ge2)
	if not copy_check then
		copy_check=true
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_CHAIN_SOLVED)
		ge4:SetOperation(Auxiliary.RegisterInheritor)
		Duel.RegisterEffect(ge4,tp)
	end
end
function Auxiliary.AnnoteeFilter(c,tp,sg,mg,ac,minc,maxc,alterf,f,...)
	sg:AddCard(c)
	local res=c:IsHasEffect(EFFECT_INHERITOR) and ((f(c,ac,tp) and mg:IsExists(Auxiliary.AnCheckRecursive,1,c,tp,sg,mg,ac,1,minc,maxc,table.unpack({...}))) or (alterf and alterf(e,tp,sg,0)))
	sg:RemoveCard(c)
	return res
end
function Auxiliary.AnCheckRecursive(c,tp,sg,mg,ac,ct,minc,maxc,...)
	sg:AddCard(c)
	ct=ct+1
	local res=Auxiliary.AnCheckGoal(tp,sg,ac,minc,ct,...)
		or (ct<maxc and mg:IsExists(Auxiliary.AnCheckRecursive,1,sg,tp,sg,mg,ac,ct,minc,maxc,...))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.AnCheckGoal(tp,sg,ac,minc,ct,...)
	local funs={...}
	for _,f in pairs(funs) do
		if not sg:IsExists(f,ct,nil) then return false end
	end
	return ct>=minc and sg:CheckWithSumEqual(Card.GetLevel,ac:GetLevel(),ct,ct,ac) and Duel.GetLocationCountFromEx(tp,tp,sg,ac)>0
end
function Auxiliary.AnnoteeCondition(minc,maxc,alterf,...)
	local funs={...}
	return function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM+TYPE_RELAY) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ct=-ft
				local minct=minc
				if minct<ct then minct=ct end
				if 99<minct then return false end
				local g=Duel.GetReleaseGroup(tp):Filter(Card.IsCanBeAnnoteeMaterial,nil,c)
				return g:IsExists(Auxiliary.AnnoteeFilter,1,nil,tp,Group.CreateGroup(),g,c,minc,maxc,alterf,table.unpack(funs))
			end
end
function Auxiliary.AnnoteeTarget(minc,maxc,alterf,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetReleaseGroup(tp):Filter(Card.IsCanBeAnnoteeMaterial,nil,c)
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_ANNOTEE_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
					bg:Select(tp,#bg,#bg,nil)
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local sg=mg:FilterSelect(tp,Auxiliary.AnnoteeFilter,1,1,nil,tp,Group.CreateGroup(),mg,c,minc,maxc,alterf,table.unpack(funs))
				table.remove(funs,1)
				local finish=false
				if alterf and alterf(e,tp,sg,0) and Duel.SelectYesNo(tp,aux.Stringid(512,0)) then
					e:SetLabel(1)
					alterf(e,tp,sg,1)
				else
					while not (#sg>=maxc) do
						finish=Auxiliary.AnCheckGoal(tp,sg,c,minc,#sg,table.unpack(funs))
						local cg=mg:Filter(Auxiliary.AnCheckRecursive,sg,tp,sg,mg,c,#sg,minc,maxc,nil,table.unpack(funs))
						if #cg==0 then break end
						local cancel=not finish
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						local tc=cg:SelectUnselect(sg,tp,finish,cancel,minc,maxc)
						if not tc then break end
						if not bg:IsContains(tc) then
							if not sg:IsContains(tc) then
								sg:AddCard(tc)
								if (#sg>=maxc) then finish=true end
							else
								sg:RemoveCard(tc)
							end
						elseif #bg>0 and #sg<=#bg then
							return false
						end
					end
				end
				if finish then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.AnnoteeOperation(e,tp,eg,ep,ev,re,r,rp,c,og,mg)
	if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	if e:GetLabel()~=1 then Duel.Release(g,REASON_MATERIAL+REASON_ANNOTEE) end
	g:DeleteGroup()
end
function Auxiliary.RegisterInheritor(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) or re:IsHasProperty(EFFECT_FLAG_INITIAL) or re:GetHandler():IsType(TYPE_ANNOTEE) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_INHERITOR)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	re:GetHandler():RegisterEffect(e1)
end
