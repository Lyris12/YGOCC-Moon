--Traptrix Praedatores
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,ref=getID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	local magick=Effect.CreateEffect(c)
	magick:SetDescription(aux.Stringid(id,0))
	magick:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	magick:SetType(EFFECT_TYPE_TRIGGER_O)
	magick:SetProperty(EFFECT_FLAG_DELAY)
	magick:SetTarget(ref.thtg)
	magick:SetOperation(ref.thop)
	aux.AddMagickProcCustom(c,ref.magcon,aux.MagickMatCost,magick,aux.TRUE,2)
	aux.AddFusionProcFunRep2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x108a),2,2,true)
	--Immune
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(ref.efilter)
	c:RegisterEffect(e0)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(ref.ngcon)
	e1:SetCost(ref.ngcost)
	e1:SetTarget(ref.ngtg)
	e1:SetOperation(ref.ngop)
	c:RegisterEffect(e1)
	--Grant
	----Effect to Grant
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(ref.postg)
	e2:SetOperation(ref.posop)
	----Grant
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0)
	e3:SetTarget(ref.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function ref.matcfilter(c,tp)
	return c:GetSummonPlayer()~=tp
end
function ref.magcon(e,tp,eg,ep,ev,re,r,rp)
	local res,xeg,xep,xev,xre,xr,xrp=Duel.CheckEvent(EVENT_SUMMON_SUCCESS,true)
	if res then return xeg:IsExists(ref.matcfilter,1,nil,tp) end
	local res,xeg,xep,xev,xre,xr,xrp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then return xeg:IsExists(ref.matcfilter,1,nil,tp) end
	local res,xeg,xep,xev,xre,xr,xrp=Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS,true)
	if res then return xeg:IsExists(ref.matcfilter,1,nil,tp) end
	return false
end
function ref.thfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsAbleToHand()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Immune
function ref.refilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
--Negate
function ref.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsControler,1,nil,tp)
end
function ref.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFacedown() end
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_ATTACK)
end
function ref.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function ref.ngop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc:IsDisabled() then
		if Duel.NegateEffect(ev) and tc:IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
--Grant
----Grant
function ref.eftg(e,c)
	return c:IsType(TYPE_TRAP)
end
----Granted Effect
function ref.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and not c:IsStatus(STATUS_SPSUMMON_TURN)
end
function ref.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and ref.posfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(ref.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,ref.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function ref.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
--Growth
function ref.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function ref.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(ref.refilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
function ref.refilter(e,te)
	return te==e:GetLabelObject()
end
