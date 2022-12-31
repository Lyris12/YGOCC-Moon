--Sinnamon Quick Summon
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,310106+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--filters
function cid.efilter0(c)
	return c:IsFaceup() and not c:IsForbidden()
end
function cid.checksummon(c,e)
	local egroup=global_card_effect_table[c]
	for i=1,#egroup do
		local ce=egroup[i]
		if not ce or ce==nil or type(ce)~="userdata" or ce:GetType()==nil then
			table.remove(egroup,i)
		else
			local code,val,cond=ce:GetCode(),ce:GetValue(),ce:GetCondition()
			if code and code==EFFECT_SPSUMMON_PROC and val and val==SUMMON_TYPE_EVOLUTE then
				if (not cond or cond(e,c)) then
					return true
				end
			end
		end
	end
	return false
end
function cid.tfunc(e,c)
	return c~=e:GetOwner()
end
function cid.extrafilter(c,mg,e)
	if not c:IsType(TYPE_MONSTER) or not c:IsType(TYPE_EVOLUTE) or (c:IsType(TYPE_PENDULUM) and c:IsFaceup()) then return end
	local sg=mg:Filter(Card.IsCanBeEvoluteMaterial,nil,c)
	sg:KeepAlive()
	local summon_check={}
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
		e1:SetRange(0xff)
		e1:SetTargetRange(0xff,0xff)
		e1:SetTarget(cid.tfunc)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		if cid.checksummon(c,e) then
			table.insert(summon_check,tc)
		end
		e1:Reset()
	end
	return #summon_check>0
end
--Activate
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(cid.efilter0,tp,LOCATION_MZONE,0,nil)
		return #mg>0 and Duel.IsExistingMatchingCard(cid.extrafilter,tp,LOCATION_EXTRA,0,1,nil,mg,e)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(cid.efilter0,tp,LOCATION_MZONE,0,nil)
	local echeck=Duel.GetMatchingGroup(cid.extrafilter,tp,LOCATION_EXTRA,0,nil,mg,e)
	if #echeck<=0 then return end
	local tc0=echeck:Select(tp,1,1,nil)
	local sg=mg:Filter(Card.IsCanBeEvoluteMaterial,nil,tc0:GetFirst()):GetFirst()
	local egroup=Group.CreateGroup()
	egroup:KeepAlive()
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
		e1:SetRange(0xff)
		e1:SetTargetRange(0xff,0xff)
		e1:SetTarget(cid.tfunc)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		if cid.checksummon(tc0:GetFirst(),e) then
			egroup:AddCard(tc)
		end
		e1:Reset()
	end
	if #egroup<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_MATERIAL)
	local sc=egroup:Select(tp,1,1,nil):GetFirst()
	local e1=Effect.CreateEffect(sc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(cid.tfunc)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,0)
	Duel.SpecialSummonRule(tp,tc0:GetFirst(),SUMMON_TYPE_EVOLUTE)
	egroup:DeleteGroup()
	e1:Reset()
end