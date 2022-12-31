---Peach Beach Cutie, Al'Miraj
function c69002.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69002,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,69002)
	e1:SetCondition(c69002.reccon)
	e1:SetCost(c69002.reccost)
	e1:SetTarget(c69002.rectg)
	e1:SetOperation(c69002.recop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1,69002+100)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c69002.spcon)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c69002.drcon)
	e3:SetTarget(c69002.drtg)
	e3:SetOperation(c69002.drop)
	e3:SetCountLimit(1,69002+200)
	c:RegisterEffect(e3)
end
function c69002.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c69002.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function c69002.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c69002.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function c69002.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLP(tp)>=Duel.GetLP(1-tp) and
		Duel.IsExistingMatchingCard(c69002.filter1,tp,LOCATION_HAND,0,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function c69002.filter(c)
	return c:IsPublic() and c:IsSetCard(0x6969)
end
function c69002.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function c69002.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local p1=Duel.GetLP(tp)
		local p2=Duel.GetLP(1-tp)
		local s=p2-p1
		if s<0 then s=p1-p2 end
		return Duel.IsPlayerCanDraw(tp,1) and math.floor(s/4000)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c69002.drop(e,tp,eg,ep,ev,re,r,rp)
	local p1=Duel.GetLP(tp)
	local p2=Duel.GetLP(1-tp)
	local s=p2-p1
	if s<0 then s=p1-p2 end
	local d=math.floor(s/4000)
	Duel.Draw(tp,d,REASON_EFFECT)
end
