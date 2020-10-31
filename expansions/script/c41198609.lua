--Kuninotokotachi
local cid,id=GetID()
function cid.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--alt xyz summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cid.xcon)
	e2:SetTarget(cid.xtg)
	e2:SetOperation(aux.XyzOperation())
	e2:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.negcon)
	e3:SetCost(cid.negcost)
	e3:SetTarget(cid.negtg)
	e3:SetOperation(cid.negop)
	c:RegisterEffect(e3)
	--return
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_FLIP)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(cid.sumsuc)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(cid.sumcon)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(cid.thcon)
	e8:SetTarget(cid.thtg)
	e8:SetOperation(cid.thop)
	c:RegisterEffect(e8)
end
function cid.xfilter(c)
	return c:IsLevel(4) and c:IsType(TYPE_SPIRIT)
end
function cid.xcon(e,c,og,min,max)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	if min and min>max then return false end
	local tp=c:GetControler()
	local mg=nil
	if og then mg=og
	else mg=Duel.GetFieldGroup(tp,LOCATION_HAND,0) end
	return (not min or min<=1) and mg:IsExists(aux.XyzAlterFilter,2,nil,cid.xfilter,c,e,tp)
end
function cid.xtg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
	if og and not min then return true end
	local mg=nil
	if og then mg=og
	else mg=Duel.GetFieldGroup(tp,LOCATION_HAND,0) end
	local g=nil
	if (not min or min<=1) and mg:IsExists(aux.XyzAlterFilter,2,nil,cid.xfilter,c,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		g=mg:FilterSelect(tp,aux.XyzAlterFilter,2,2,nil,cid.xfilter,c,e,tp)
	end
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and 
		(re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) 
		and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,e:GetHandler(),TYPE_SPIRIT)
end
function cid.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbcon(tp,re) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function cid.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cid.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAbleToHand,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,e:GetHandler():GetOverlayGroup())
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local oc=c:GetOverlayCount()
	if oc>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=c:GetOverlayGroup():FilterSelect(tp,Card.IsAbleToHand,oc,oc,nil,e,tp)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end