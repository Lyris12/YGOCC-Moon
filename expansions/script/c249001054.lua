--Absolute Ritual Sage
function c249001054.initial_effect(c)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1108)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,249001054)
	e1:SetCondition(c249001054.con)
	e1:SetTarget(c249001054.tg)
	e1:SetOperation(c249001054.op)
	c:RegisterEffect(e1)
	--spsummon proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249001054.spcon)
	c:RegisterEffect(e2)
	--act limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c249001054.chainop)
	c:RegisterEffect(e3)
end
function c249001054.confilter(c)
	return c:IsSetCard(0x225) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not c:IsCode(249001054)
end
function c249001054.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and r==REASON_RITUAL and Duel.IsExistingMatchingCard(c249001054.confilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function c249001054.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c249001054.op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function c249001054.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c249001054.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(0x225) and re:IsActiveType(TYPE_RITUAL) and re:IsActiveType(TYPE_SPELL) then
		Duel.SetChainLimit(c249001054.chainlm)
	end
end
function c249001054.chainlm(e,rp,tp)
	return tp==rp
end