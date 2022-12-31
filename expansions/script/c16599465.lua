--Tertius dell'Organizzazione Angeli, Brinace
--Script by XGlitchy30
function c16599465.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),aux.NonTuner(Card.IsSetCard,0x1559),1)
	c:EnableReviveLimit()
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599465.efilter)
	c:RegisterEffect(e0)
	--bounce
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c16599465.thcon)
	e1:SetCost(c16599465.thcost)
	e1:SetTarget(c16599465.thtg)
	e1:SetOperation(c16599465.thop)
	c:RegisterEffect(e1)
	--draw
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetCategory(CATEGORY_DRAW)
	-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_PLAYER_TARGET)
	-- e2:SetCode(EVENT_BATTLE_DAMAGE)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetCondition(c16599465.damcon)
	-- e2:SetTarget(c16599465.damtg)
	-- e2:SetOperation(c16599465.damop)
	-- c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,16599465)
	e3:SetCondition(c16599465.sccon)
	e3:SetTarget(c16599465.sctg)
	e3:SetOperation(c16599465.scop)
	c:RegisterEffect(e3)
end
--filters
function c16599465.mfilter(c,sync)
	return c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsAbleToRemoveAsCost()
end
function c16599465.tdfilter(c,tp)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
end
function c16599465.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
function c16599465.tgfilter(c)
	return c:IsSetCard(0x1559) and c:IsAbleToGrave()
end
function c16599465.scfilter(c)
	return c:IsSetCard(0x1559) and c:IsAbleToHand()
end
function c16599465.exclude(c,card)
	return c==card
end
function c16599465.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1559) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--target protection
function c16599465.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(7)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=7)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--bounce set cards
function c16599465.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c16599465.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local matc=mat:GetCount()
	if chk==0 then return matc>0 and mat:FilterCount(c16599465.mfilter,nil,c)==matc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=mat:Select(tp,matc,matc,nil)
	if g:GetCount()==matc then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599465.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c16599465.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
function c16599465.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c16599465.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			local tc=Duel.GetFirstTarget()
			if tc and tc:IsRelateToEffect(e) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end
--draw
-- function c16599465.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- local att=Duel.GetAttacker()
	-- local def=Duel.GetAttackTarget()
	-- return ep==tp and att and def
		-- and ((att:GetControler()==tp and att:IsRace(RACE_FAIRY) and att:IsRelateToBattle())
		-- or (def:GetControler()==tp and def:IsRace(RACE_FAIRY) and def:IsRelateToBattle()))
-- end
-- function c16599465.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- Duel.SetTargetPlayer(tp)
	-- Duel.SetTargetParam(1)
	-- Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
-- end
-- function c16599465.damop(e,tp,eg,ep,ev,re,r,rp)
	-- local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- Duel.Draw(p,d,REASON_EFFECT)
-- end
--search
function c16599465.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and re:GetHandler():IsType(TYPE_SYNCHRO)
end
function c16599465.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16599465.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c16599465.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c16599465.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c16599465.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function c16599465.sumlimit(e,c)
	return c:GetRace()~=RACE_FAIRY
end