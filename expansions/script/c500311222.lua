--Demonic Plant Mosquito elephant
function c500311222.initial_effect(c)
		 --summon success
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(500311222,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,500311222)
	e3:SetTarget(c500311222.sptg)
	e3:SetOperation(c500311222.spop)
	c:RegisterEffect(e3)
	  --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,500311222)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c500311222.thtg)
	e2:SetOperation(c500311222.thop)
	c:RegisterEffect(e2)
end
function c500311222.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x485a)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c500311222.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
 and c:GetLevel() ~= 2
		and Duel.IsExistingMatchingCard(c500311222.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c500311222.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c500311222.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()~=0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) ~=0 then
	   local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
		
	end
end
function c500311222.thfilter(c)
	return c:IsSetCard(0x485a) and c:IsType(TYPE_MONSTER) and not c:IsCode(500311222) and c:IsAbleToHand()
end
function c500311222.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c500311222.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c500311222.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c500311222.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end