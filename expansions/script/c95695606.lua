--Skyburner Scorched Earth Policy
--Commissioned by: Leon Duvall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(cid.condition)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
--DAMAGE
--filters
function cid.cfilter(c,tp)
	return c:IsControler(1-tp) and c:GetPreviousControler()==1-tp
end
function cid.refilter(c,tp,re)
	return c:IsControler(1-tp) and c:GetPreviousControler()==1-tp and c:IsReason(REASON_EFFECT)
		and re and re:GetHandler():IsSetCard(0xf41) and re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsControler(tp)
end
---------
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x40)==0x40 and re and re:GetHandler():IsSetCard(0xf41) and re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsControler(tp)
		and eg:IsExists(cid.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	local g=eg:Filter(cid.refilter,nil,tp,re)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			local rg=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			if #rg<=0 then return end
			Duel.Damage(1-tp,#rg*300,REASON_EFFECT)
		end
	end
end