--S.G. Generator
function c21730401.initial_effect(c)
	--special summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21730401,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c21730401.spcon)
	c:RegisterEffect(e1)
	--add from deck to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21730401,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_END_PHASE)
	e2:SetCost(c21730401.thcost)
	e2:SetTarget(c21730401.thtg)
	e2:SetOperation(c21730401.thop)
	c:RegisterEffect(e2)
end
--special summon from hand
function c21730401.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
--add from deck to hand
function c21730401.thfilter1(c)
	return c:IsSetCard(0x719)
end
function c21730401.thfilter2(c)
	return c:IsSetCard(0x719) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c21730401.rcost(c)
	return c:IsCode(21730411) and c:IsReleasable() and not c:IsDisabled() and not c:IsForbidden()
end
function c21730401.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.CheckReleaseGroup(tp,c21730401.thfilter,1,false,nil,nil,tp)
	local b2=Duel.IsExistingMatchingCard(c21730401.rcost,tp,LOCATION_FZONE,0,1,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost() and (b1 or b2) end
	if Duel.Remove(c,POS_FACEUP,REASON_COST)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TURN_END)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetOperation(c21730401.tgop)
		c:RegisterEffect(e1)
	end
	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(21730411,1))) then
		local tg=Duel.GetFirstMatchingCard(c21730401.rcost,tp,LOCATION_FZONE,0,nil)
		Duel.Release(tg,REASON_COST)
	else
		local g=Duel.SelectReleaseGroup(tp,c21730401.thfilter,1,1,false,nil,nil,tp)
		Duel.Release(g,REASON_COST)
	end
end
function c21730401.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21730401.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21730401.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21730401.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--return to grave
function c21730401.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_RETURN)
end