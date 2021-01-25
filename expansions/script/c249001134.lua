--Naviigator White Paladin
function c249001134.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2490011341)
	e1:SetCost(c249001134.cost)
	e1:SetTarget(c249001134.target)
	e1:SetOperation(c249001134.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--todeck
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,2490011342)
	e4:SetCondition(aux.exccon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c249001134.target2)
	e4:SetOperation(c249001134.operation2)
	c:RegisterEffect(e4)
end
function c249001134.cfilter(c)
	return c:IsSetCard(0x22B) and not c:IsPublic()
end
function c249001134.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001134.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c249001134.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c249001134.filter(c,e,tp,lv)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv)
end
function c249001134.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
		and Duel.IsExistingMatchingCard(c249001134.filter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetHandler():GetLevel()-1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function c249001134.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=c:GetLevel()-1
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if not Duel.IsPlayerCanSpecialSummon(tp) or dcount < 1
		or not Duel.IsExistingMatchingCard(c249001134.filter,tp,LOCATION_DECK,0,1,nil,e,tp,lv) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ct=1
	local g=Duel.GetDecktopGroup(tp,ct)
	local tc=g:GetFirst()
	local spcard=nil
	while ct<=dcount do
		if c249001134.filter(tc,e,tp,lv) then
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
function c249001134.filter2(c)
	return c:IsSetCard(0x22B) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) 
end
function c249001134.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c249001134.filter2(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(c249001134.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c249001134.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001134.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end