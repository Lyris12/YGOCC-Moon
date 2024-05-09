--created by Slick, coded by Lyris
--Kronologistics Centaurea
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:RegisterSetCardString"Kronologistic"
	aux.AddSynchroMixProcedure(c,nil,nil,nil,aux.NonTuner(nil),1,99,s.mchk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(s.tnval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(s.ndtg)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:HOPT()
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetCondition(s.zecon)
	e5:SetTarget(s.zetg)
	e5:SetOperation(s.zeop)
	c:RegisterEffect(e5)
end
function s.mchk(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_DRIVE)
end
function s.thcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c)
	return (c:IsSetCard"Kronologistic" and c:IsType(TYPE_MONSTER) or c:IsCode(212111811)) and c:IsAbleToHand()
end
function s.thtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
function s.ndtg(e,c)
	return c:IsEngaged() and c:IsSetCard"Kronologistic"
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return te:IsDriveEffect() and te:GetHandlerPlayer()==e:GetHandlerPlayer() and tc:IsEngaged()
		and tc:IsSetCard"Kronologistic"
end
function s.zecon(_,tp)
	return Duel.IsEnvironment(212111811,tp)
end
function s.zetg(e,tp,_,_,_,_,_,_,chk)
	local g=Duel.GetEngagedCards():Filter(Card.IsHasEnergy,nil)
	local b=g:IsExists(Card.IsControler,1,nil,tp)
	if chk==0 then return #g>0 and (not b or Duel.IsPlayerCanDraw(tp,2)) end
	if b then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2) end
end
function s.zeop(e,tp)
	local g,b=Duel.GetEngagedCards():Filter(Card.IsHasEnergy,nil)
	for tc in aux.Next(g) do
		if tc:IsControler(tp) then b=true end
		tc:ChangeEnergy(0,tp,REASON_EFFECT,0,e:GetHandler())
	end
	if b then Duel.Draw(tp,2,REASON_EFFECT) end
end
