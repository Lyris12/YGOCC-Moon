--Red Scale Dragon Aquabizarre
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition2)
	e1:SetTarget(s.target2)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL) and re:IsActiveType(TYPE_CONTINUOUS+TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
	function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
	function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
	function s.filta(c,tp,code)
	local ae=c:GetActivateEffect()
	return ae and ae:IsActivatable(tp,true) and c:IsSetCard(0xb23) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and not c:IsCode(code)
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
	Duel.IsExistingMatchingCard(s.filta,tp,LOCATION_DECK,0,1,nil,tp,code) end
end
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local code=tc:GetCode()
		if tc:IsType(TYPE_SPELL) and tc:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and Duel.GetMatchingGroup(s.filta,tp,LOCATION_DECK,0,1,nil,tp,code) then
		local tr=Duel.GetMatchingGroup(s.filta,tp,LOCATION_DECK,0,nil,tp,code)
			if tr:GetCount()>0 then
			Duel.Remove(tc,REASON_TEMPORARY)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sg=tr:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
				if sc and sc:IsType(TYPE_CONTINUOUS) then
				Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				Duel.ShuffleDeck(tp)
			local te=sc:GetActivateEffect()
				Duel.SendtoDeck(tc,nil,0,REASON_EFFECT+REASON_REVEAL)
			elseif sc and sc:IsType(TYPE_FIELD) then
				Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				Duel.ShuffleDeck(tp)
			local te=sc:GetActivateEffect()
				Duel.SendtoDeck(tc,nil,0,REASON_EFFECT+REASON_REVEAL)
			else
				Duel.DisableShuffleCheck()
				Duel.SendtoDeck(tc,nil,0,REASON_EFFECT+REASON_REVEAL)
			end
		end
	end
end