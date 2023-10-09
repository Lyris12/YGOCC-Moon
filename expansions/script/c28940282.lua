--Ellien, Sunhewn Pupil
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	Sunhew.EnableDisengage()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ENGAGE)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp end)
	e1:SetTarget(ref.sptg)
	e1:SetOperation(ref.spop)
	c:RegisterEffect(e1)
	--Activate
	local e2=Sunhew.LeaveHandTemplate(c)
	e2:Desc(2)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(ref.acttg)
	e2:SetOperation(ref.actop)
	c:RegisterEffect(e2)
end

--Special Summon
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function ref.tdfilter(c) return Sunhew.Is(c) and c:IsLocation(LOCATION_REMOVED) and c:IsAbleToDeck() end
function ref.tdgfilter(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<3
		and g:FilterCount(ref.tdfilter,nil)<3
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(ref.tdfilter,tp,LOCATION_REMOVED,0,nil)
	g:Merge(Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil))
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and g:CheckSubGroup(ref.tdgfilter,4,4) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:SelectSubGroup(tp,ref.tdgfilter,true,4,4)
		if #sg>0 then Duel.SendtoDeck(sg,nil,2,REASON_EFFECT) end
	end
end

--Activate
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden()
	end
end
function ref.actop(e,tp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e1)
		if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT-RESET_MSCHANGE)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
			Duel.RaiseEvent(c,73734821,te,0,tp,tp,Duel.GetCurrentChain())
		else e1:Reset() end
	end
end
