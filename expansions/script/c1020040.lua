--Bushido Toad
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cid.untargetable)
	c:RegisterEffect(e1)
	--secure bushido summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetOperation(cid.effect)
	c:RegisterEffect(e2)
	--recycle
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--filters
function cid.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4b0) and c:IsAbleToHand()
end
function cid.sumcheck(c)
	return c:IsSetCard(0x4b0)
end
--values
function cid.untargetable(e,re,rp)
	return rp~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
--secure bushido summon
function cid.effect(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EVENT_SUMMON_SUCCESS)
	e11:SetCondition(cid.uchcon)
	e11:SetOperation(cid.unchainable)
	e11:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e11)
end
function cid.chainlm(e,rp,tp)
	return tp==rp
end
function cid.uchcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.sumcheck,1,nil)
end
function cid.unchainable(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(cid.chainlm)
end
--recycle
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cid.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	local lp=g:GetFirst():GetLevel()*300
	Duel.SetTargetParam(lp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,lp)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		local lp=tc:GetLevel()*300
		Duel.Recover(tp,lp,REASON_EFFECT)
	end
end