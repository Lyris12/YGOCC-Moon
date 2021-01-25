--Naviigator Dark Knight
function c249001137.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,249001137)
	e1:SetCost(c249001137.cost)
	e1:SetTarget(c249001137.target)
	e1:SetOperation(c249001137.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(502)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c249001137.cost2)
	e4:SetTarget(c249001137.target2)
	e4:SetOperation(c249001137.operation2)
	c:RegisterEffect(e4)
end
function c249001137.cfilter(c)
	return c:IsSetCard(0x22B) and not c:IsPublic()
end
function c249001137.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001137.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c249001137.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c249001137.filter(c,e,tp,lv)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv)
end
function c249001137.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
		and Duel.IsExistingMatchingCard(c249001137.filter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetHandler():GetLevel()-1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function c249001137.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=c:GetLevel()-1
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if not Duel.IsPlayerCanSpecialSummon(tp) or dcount < 1
		or not Duel.IsExistingMatchingCard(c249001137.filter,tp,LOCATION_DECK,0,1,nil,e,tp,lv) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ct=1
	local g=Duel.GetDecktopGroup(tp,ct)
	local tc=g:GetFirst()
	local spcard=nil
	while ct<=dcount do
		if c249001137.filter(tc,e,tp,lv) then
			spcard=tc
			break
		end
		ct=ct+1
		if ct>dcount-1 then
			Duel.ConfirmDecktop(tp,dcount)
			Duel.ShuffleDeck(tp)
			return
		end
		tc=Duel.GetDecktopGroup(tp,ct):GetFirst()
	end
	Duel.ConfirmDecktop(tp,ct)
	if spcard then
		if spcard:IsSetCard(0x22B) then
			Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			if Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				spcard:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				spcard:RegisterEffect(e2)
				Duel.SpecialSummonComplete()
			end
		end
	end
end
function c249001137.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function c249001137.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249001137.operation2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end