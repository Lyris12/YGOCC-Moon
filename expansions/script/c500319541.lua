--Winged Beast Of Gust Vine
function c500319541.initial_effect(c)
				aux.AddFusionProcFunRep(c,c500319541.ffilter,2,false)
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500319541,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,500319541)
	e1:SetCondition(c500319541.condition)
	e1:SetTarget(c500319541.target)
	e1:SetOperation(c500319541.operation)
	c:RegisterEffect(e1)
		--tohand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(500319541,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,500319541)
	e4:SetCondition(c500319541.thcon)
	e4:SetTarget(c500319541.thtg)
	e4:SetOperation(c500319541.thop)
	c:RegisterEffect(e4)
	end
function c500319541.ffilter(c)
	return c:IsSetCard(0x885a) and not c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER)

end
function c500319541.condition(e,tp,eg,ep,ev,re,r,rp)
	return(e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION or e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION+0x786) and re:GetHandler():IsSetCard(0x885a)
end
function c500319541.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,30459350) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
	function c500319541.mrfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x885a) or c:IsAttribute(ATTRIBUTE_WIND)
end
function c500319541.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(p,c500319541.mrfilter,p,LOCATION_HAND,0,1,1,nil)
	local tg=g:GetFirst()
	if tg then
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
			Duel.ConfirmCards(1-p,tg)
			Duel.ShuffleHand(p)
		end
	else
	Duel.Remove(Duel.GetFieldGroup(p,LOCATION_HAND),POS_FACEUP,REASON_EFFECT)
	end
end

function c500319541.thfilter(c)
	return c:IsSetCard(0x885a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function c500319541.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function c500319541.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c500319541.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500319541.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c500319541.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c500319541.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end