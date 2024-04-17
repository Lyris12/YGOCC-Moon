--[[
Eternadir Commander Eizu
Comandante Eternadir Eizu
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.EnablePendulumAttribute(c,false)
	--Register Activation
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_ACTIVATE)
	reg:SetCode(EVENT_FREE_CHAIN)
	reg:SetRange(LOCATION_HAND)
	reg:SetCost(s.reg)
	c:RegisterEffect(reg)
	--[[You cannot Pendulum Summon monsters, except "Eternadir" monsters.]]
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CAN_FORBIDDEN|EFFECT_FLAG_UNCOPYABLE)
	p1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(1,0)
	p1:SetTarget(s.splimit)
	c:RegisterEffect(p1)
	--[[Once per turn, during your Main Phase, if this card was activated this turn: You can target 1 card in your Pendulum Zone, except "Eternadir Commander Eizu";
	return it to the hand, and if you do, send 1 "Eternadir" card from your Deck to the GY.]]
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORY_TOHAND|CATEGORY_TOGRAVE)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p2:SetRange(LOCATION_PZONE)
	p2:OPT()
	p2:SetFunctions(s.discon,nil,s.distg,s.disop)
	c:RegisterEffect(p2)
	--Must be Pendulum Summoned.
	aux.EnableReviveLimitPendulumSummonable(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit_self)
	c:RegisterEffect(e0)
	--[[Once per turn, when this card destroys an opponent's monster by battle: You can Tribute 1 other "Eternadir" monster; this card can make a second attack in a row.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:OPT()
	e1:SetFunctions(s.atkcon,s.atkcost,aux.DummyCost,s.atkop)
	c:RegisterEffect(e1)
	--If this card on the field is destroyed: You can add 1 face-up "Eternadir" monster from your Extra Deck to your hand, except "Eternadir Commander Eizu".
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end

--P1
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard(ARCHE_ETERNADIR)
end

--P2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
function s.thfilter(c)
	return c:IsAbleToHand() and (not c:IsFaceup() or not c:IsCode(id))
end
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsAbleToGrave()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TOHAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc) then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E0
function s.splimit_self(e,se,sp,st)
	return (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

--E1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsChainAttackable() and c:IsStatus(STATUS_OPPO_BATTLE)
end
function s.cfilter(c,tp)
	return c:IsSetCard(ARCHE_ETERNADIR) and (c:IsControler(tp) or c:IsFaceup())
end
function s.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(CARD_ETERNADIR_SCOUT_ESOM,tp)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetReleaseGroup(tp):Filter(s.cfilter,c,tp)
	local og1=g1:Clone()
	local g2=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	local exchk=#g2>0
	g1:Merge(g2)
	if chk==0 then return #g1>0 end
	if exchk and Duel.SelectYesNo(tp,aux.Stringid(CARD_ETERNADIR_SCOUT_ESOM,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=g2:Select(tp,1,1,nil)
		local tc=rg:GetFirst()
		local te=tc:IsHasEffect(CARD_ETERNADIR_SCOUT_ESOM,tp)
		Duel.Hint(HINT_CARD,0,tc)
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_COST|REASON_REPLACE)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local rg=g1:Select(tp,1,1,nil)
		local tc=rg:GetFirst()
		aux.UseExtraReleaseCount(rg,tp)
		Duel.Release(tc,REASON_COST)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end

--E2
function s.thcon(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_ETERNADIR) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end