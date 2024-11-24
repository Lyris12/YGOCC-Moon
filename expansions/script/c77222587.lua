--Ignitronix Engine
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,12)
	--function Card.DriveEffect(c,energycost,desc,category,typ,property,event,condition,cost,target,operation,hold_registration,setlabelcost,shopt,enchk)
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	--All "Ignitronix" monsters you control gain 600 ATK/DEF.
	local d1=c:DriveEffect(0,0,nil,EFFECT_TYPE_FIELD,nil,EFFECT_UPDATE_ATTACK,
		nil,
		nil,
		{LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0x725)},
		600
	)
	local d2=c:DriveEffect(0,0,nil,EFFECT_TYPE_FIELD,nil,EFFECT_UPDATE_DEFENSE,
		nil,
		nil,
		{LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0x725)},
		600
	)
	--[-3]: Special Summon 1 "Ignitronix" monster from your Deck, except "Ignitronix Engine", also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except FIRE monsters.
	local d3=c:DriveEffect(-3,0,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		s.spcost,
		s.sptg,
		s.spop
	)
	--If this card is in your GY: You can banish 1 Positive and 1 Negative FIRE monster from your GY; add this card to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY due to having 0 Energy: Destroy 1 card on the field.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--While you control this Drive Summoned card, All "Ignitronix" monsters you control gain 600 ATK/DEF.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x725))
	e3:SetValue(600)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x725) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLocation(LOCATION_EXTRA)
end
function s.thfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsPositive() or c:IsNegative())
end
function s.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsPositive,nil)==1 and sg:FilterCount(Card.IsNegative,nil)==1
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,c)
	if chk==0 then return rg:CheckSubGroup(s.fgoal,2,2,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=rg:SelectSubGroup(tp,s.fgoal,false,2,2,e,tp)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():HasFlagEffect(FLAG_ZERO_ENERGY)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end