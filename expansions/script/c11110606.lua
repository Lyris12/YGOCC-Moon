--Titania, Demimetalurgos Pilot
--Titania, Demimetalurgo Pilota
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,3,3)
	--[[If this card is Bigbang Summoned: You can target 1 "Metalurgos" Continuous Spell in your GY; place it in your Spell & Trap Zone face-up,
	then this card gains 750 ATK/DEF for each "Metalurgos" card you currently control.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.BigbangSummonedCond)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	--[[Once per Chain, when a monster effect is activated (Quick Effect): You can either make this card lose exactly 750 ATK, or destroy 1 face-up "Metalurgos" Continuous Spell you control,
	and if you do, apply 1 of these effects (but you cannot apply the same effect of "Titania, Demimetalurgos Pilot" again this turn).
	● Negate that effect.
	● Destroy 1 monster on the field.
	● Destroy 1 Spell/Trap on the field..]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.disdescon)
	e2:SetTarget(s.disdestg)
	e2:SetOperation(s.disdesop)
	c:RegisterEffect(e2)	
end
--FILTERS E1
function s.pcfilter(c,tp)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_METALURGOS)
end
--E1
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.pcfilter(chkc,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.pcfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.pcfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_LEAVE_GRAVE)
	local c=e:GetHandler()
	local val=(Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_ONFIELD,0,nil)+1)*750
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,val)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,c,1,tp,LOCATION_MZONE,val)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		if tc:IsFaceup() and tc:IsInBackrow() then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsFaceup() then
				local val=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_ONFIELD,0,nil)*750
				if val>0 then
					Duel.BreakEffect()
					c:UpdateATKDEF(val,val,true,c)
				end
			end
		end
	end
end

--FILTERS E2
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS)
end
--E2
function s.disdescon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.disdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:HasFlagEffect(id) or (not c:IsAbleToDecreaseAttackAsCost(750) and not Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)) then return false end
		local b1 = Duel.IsChainDisablable(ev) and not Duel.PlayerHasFlagEffectLabel(tp,id,1)
		local b2 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 and not Duel.PlayerHasFlagEffectLabel(tp,id,2)
		local b3 = Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and not Duel.PlayerHasFlagEffectLabel(tp,id,3)
		return b1 or b2 or b3
	end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.disdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a1 = c:IsRelateToChain() and c:IsAbleToDecreaseAttackAsCost(750)
	local a2 = Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if not a1 and not a2 then return end
	local res=false
	local opt=aux.Option(tp,id,2,a1,a2)
	if opt==0 then
		local eatk,diff=c:UpdateATK(-750,true,c)
		if not c:IsImmuneToEffect(eatk) and diff==-750 then
			res=true
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if Duel.Destroy(g,REASON_EFFECT)>0 then
				res=true
			end
		end
	end
	if res then
		local b1 = Duel.IsChainDisablable(ev) and not Duel.PlayerHasFlagEffectLabel(tp,id,1)
		local b2 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 and not Duel.PlayerHasFlagEffectLabel(tp,id,2)
		local b3 = Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and not Duel.PlayerHasFlagEffectLabel(tp,id,3)
		local opt=aux.Option(tp,id,4,b1,b2,b3)
		if opt==0 then
			Duel.NegateEffect(ev)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,1)
		elseif opt==1 or opt==2 then
			local f = opt==1 and aux.TRUE or Card.IsSpellTrapOnField
			local loc = opt==1 and LOCATION_MZONE or LOCATION_ONFIELD
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,f,tp,loc,loc,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Destroy(g,REASON_EFFECT)
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,opt+1)
			end
		end
	end
end