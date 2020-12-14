--created by Eaden, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,function(g) return g:IsExists(Card.IsLinkSetCard,1,nil,0xead) end)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_XYZATTACH)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetTarget(s.lgtg)
	e2:SetOperation(s.lgop)
	c:RegisterEffect(e2)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local chd=Duel.GetCurrentChain()
	local eid=Duel.GetFlagEffectLabel(tp,id+1)
	local i=Duel.GetChainInfo(chd,CHAININFO_CHAIN_ID)
	if chd>0 and (not eid or eid~=i) then
		local v=eg:FilterCount(s.cfilter,nil)
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetOperation(function(e,tp,efg,ep,ev,re,r,rp) Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,v) end)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id+1,RESET_CHAIN,0,1,i)
	end
end
function s.cfilter(c)
	return c:GetOverlayTarget():IsSetCard(0x2ead)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ev>0 and Duel.GetFlagEffect(tp,id)==0
end
function s.xfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xead) and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	local b1,b2=g:IsExists(Card.IsAbleToGrave,1,nil),Duel.IsExistingMatchingCard(s.xfilter,p,LOCATION_MZONE,0,1,nil)
	if not b1 and not b2 then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_XMATERIAL)
	local sg=g:Select(p,1,1,nil)
	if not sg:GetFirst():IsAbleToGrave() or b2 and not Duel.SelectYesNo(tp,1191) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.Overlay(Duel.SelectMatchingCard(p,s.xfilter,p,LOCATION_MZONE,0,1,1,nil):GetFirst(),sg)
	else Duel.SendtoGrave(sg,REASON_EFFECT) end
end
function s.filter(c,tp)
	return c:IsSetCard(0xead) and (Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE,0,1,nil) or c:IsAbleToHand())
end
function s.lgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp),0,0,0)
end
function s.lgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 and (not tc:IsAbleToHand() or not Duel.SelectYesNo(tp,1152)) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.Overlay(g:Select(tp,1,1,nil):GetFirst(),Group.FromCards(tc))
	else Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
