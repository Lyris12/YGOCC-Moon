--Vioxna, Knights of the Fallen
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Shuffle Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x190)
end
function s.lamfilter(c)
	return c:IsSetCard(0x190) and c:IsType(TYPE_LINK)
end
function s.spzone(g,p)
	local zone=0
	for c in aux.Next(g) do
		zone=zone|c:GetLinkedZone(p)
	end
	return zone
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local zone=s.spzone(Duel.GetMatchingGroup(s.lamfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil),tp)
	return tc:IsControler(tp) and tc:IsSetCard(0x190) and tc:IsSummonType(SUMMON_TYPE_LINK)
	and zone~=0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=s.spzone(Duel.GetMatchingGroup(s.lamfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil),tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=s.spzone(Duel.GetMatchingGroup(s.lamfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil),tp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zone)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e:GetHandler():RegisterEffect(e1,true)	
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner():IsSetCard(0x190)
end
function s.tdfilter(c)
	return c:IsSetCard(0x190) and c:IsAbleToDeck() and ((c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) or (c:IsLocation(LOCATION_GRAVE)))
end
function s.desfilter(c)
	return c:IsDestructable()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_SZONE,nil)
		if #g2>0 and e:GetHandler():GetFlagEffect(id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local tc1=g2:Select(tp,1,1,s.desfilter)
		Duel.Destroy(tc1,REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end