--Flibberty Doofinboopler
local cid,id=GetID()
function cid.initial_effect(c)
	--flip
	local e0=Effect.CreateEffect(c)
	--e0:SetDescription(aux.Stringid(96381979,0))
	e0:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCountLimit(1,id)
	e0:SetTarget(cid.target)
	e0:SetOperation(cid.operation)
	c:RegisterEffect(e0)
	--Gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cid.acop)
	c:RegisterEffect(e2)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,LOCATION_GRAVE)>0
		and Duel.IsPlayerCanDraw(tp,1)  end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
	if aux.NecroValleyNegateCheck(g) then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5855)
end
function cid.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsExists(cid.cfilter,1,e:GetHandler()) then
		Duel.Recover(tp,100,REASON_EFFECT)
	end
end