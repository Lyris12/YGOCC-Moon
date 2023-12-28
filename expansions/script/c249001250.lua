--Neo World's Celestial Miracle
function c249001250.initial_effect(c)
	c:EnableCounterPermit(0x54)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c249001250.cost)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c249001250.tgcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(c249001250.tgcon)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--addcounter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c249001250.ctop)
	c:RegisterEffect(e4)
	--halve damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(c249001250.damcon)
	e5:SetValue(c249001250.val)
	c:RegisterEffect(e5)
	--spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(2)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c249001250.spcon)
	e6:SetTarget(c249001250.sptg)
	e6:SetOperation(c249001250.spop)
	c:RegisterEffect(e6)
end
function c249001250.costfilter(c)
	return c:IsSetCard(0x236) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(1)
end
function c249001250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001250.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001250.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001250.tgconfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x236)
end
function c249001250.tgcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_SZONE,0)>1 or Duel.IsExistingMatchingCard(c249001250.tgconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249001250.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousLevelOnField()>=1
end
function c249001250.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c249001250.ctfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x54,ct,true)
	end
end
function c249001250.damcon(e)
	return e:GetHandler():GetCounter(0x54)>1
end
function c249001250.val(e,re,dam,r,rp,rc)
	return math.floor(dam/2)
end
function c249001250.spcon(e)
	return e:GetHandler():GetCounter(0x54)>3
end
function c249001250.filter2(c,cc,e,tp,rc,att)
	return c:GetLink()>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and c:IsRace(rc)
	and c:IsAttribute(att) and cc:IsCanRemoveCounter(tp,0x54,c:GetLink() * 2,REASON_COST) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c249001250.filter1(c,cc,e,tp)
	return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(c249001250.filter2,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler(),e,tp,c:GetRace(),c:GetAttribute())
end
function c249001250.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001250.filter1,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler(),e,tp) end
	local g1=Duel.GetMatchingGroup(c249001250.filter1,tp,LOCATION_GRAVE,0,nil,e:GetHandler(),e,tp)
	local g=Group.CreateGroup()
	local tc=g1:GetFirst()
	while tc do

		local sg=Duel.GetMatchingGroup(c249001250.filter2,tp,LOCATION_EXTRA,0,nil,e:GetHandler(),e,tp,tc:GetRace(),tc:GetAttribute())
		g:Merge(sg)
		tc=g1:GetNext()
	end
	local lvt={}
	tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLink() * 2
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,99 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6061630,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x54,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249001250.sfilter2(c,lv,e,tp,rc,att)
	return c:GetLink()==math.floor(lv / 2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and c:IsRace(rc)
	and c:IsAttribute(att)
end
function c249001250.sfilter1(c,lv,e,tp)
	return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(c249001250.sfilter2,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp,c:GetRace(),c:GetAttribute())
end
function c249001250.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001250.sfilter1),tp,LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		g=Duel.SelectMatchingCard(tp,c249001250.sfilter2,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,tc:GetRace(),tc:GetAttribute())
		if g:GetCount()>0 then
			local sc=g:GetFirst()
			sc:SetMaterial(Group.FromCards(tc))
			Duel.SpecialSummon(g,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end