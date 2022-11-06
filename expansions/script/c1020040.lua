--Rospo Bushido
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
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
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
	e3:SetCountLimit(1,id+100)
	e3:SetCost(cid.thcost)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--filters
function cid.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4b0) and c:IsAbleToHand()
end
function cid.sumcheck(c)
	return c:IsFaceup() and c:IsSetCard(0x4b0)
end
--values
function cid.untargetable(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rc:IsControler(1-e:GetHandlerPlayer()) and rc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
--secure bushido summon
function cid.effect(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cid.uchcon)
	e1:SetOperation(cid.unchainable)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
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
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.thfilter(chkc) end
	if chk==0 then
		local exc = e:GetLabel()==1 and e:GetHandler() or nil
		e:SetLabel(0)
		return Duel.IsExistingTarget(cid.thfilter,tp,LOCATION_GRAVE,0,1,exc)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cid.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_GRAVE)
	local tc=g:GetFirst()
	if tc:HasLevel() and tc:IsLevelAbove(1) then
		local lp=tc:GetLevel()*300
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,lp)
	end
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		if not tc:HasLevel() or tc:GetLevel()<=0 then return end
		local lp=tc:GetLevel()*300
		Duel.Recover(tp,lp,REASON_EFFECT)
	end
end