function c79854524.initial_effect(c)
local e1=Effect.CreateEffect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79854524,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c79854524.srcon)
	e1:SetTarget(c79854524.srtg)
	e1:SetOperation(c79854524.srop)
	c:RegisterEffect(e1)
	--nontuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	c:RegisterEffect(e2)
	--plant restriction is missing -- plant restriction is not possible
	--level change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetCondition(c79854524.lvcon)
	e3:SetValue(3)
	c:RegisterEffect(e3)
end
--search
function c79854524.srcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO)==0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c79854524.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c79854524.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
function c79854524.srop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c79854524.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--level change
function c79854524.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
function c79854524.lvcon(e)
	return Duel.IsExistingMatchingCard(c79854524.lvfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end