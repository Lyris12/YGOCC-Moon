--[[
Eternadir Dragon Endeirred
Drago Eternadir Endeirred
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
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
	--[[During your Main Phase, if this card was activated this turn: You can target 1 of your "Eternadir" monsters that is banished or in your GY; add it to your hand.]]
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORY_TOHAND)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p2:SetRange(LOCATION_PZONE)
	p2:HOPT()
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
	--[[When this card declares an attack on opponent's monster: You can Tribute 1 other "Eternadir" monster; this card gains ATK equal to the ATK of that opponent's monster
	(until the end of this turn), also neither player takes battle damage from that battle.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetFunctions(s.atkcon,s.atkcost,s.atktg,s.atkop)
	c:RegisterEffect(e1)
	--If this card on the field is destroyed: You can draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetFunctions(s.drawcon,nil,s.drawtg,s.drawop)
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
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_ETERNADIR) and c:IsAbleToHand()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GB,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GB,0,1,1,nil):GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TOHAND)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc,tp)
	end
end

--E0
function s.splimit_self(e,se,sp,st)
	return (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

--E1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:IsControler(1-tp)
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
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsCanChangeAttack() and bc:HasAttack() end
	Duel.SetTargetCard(bc)
	local p,loc=c:GetResidence()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,p,loc,bc:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToChain() or not c:IsRelateToBattle() or not c:IsCanChangeAttack()
		or not tc or tc:IsFacedown() or not tc:HasAttack() or not tc:IsRelateToChain() or not tc:IsRelateToBattle() or not tc:IsControler(1-tp) then
		return
	end
	local atk=tc:GetAttack()
	c:UpdateATK(atk,RESET_PHASE|PHASE_END,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

--E2
function s.drawcon(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end