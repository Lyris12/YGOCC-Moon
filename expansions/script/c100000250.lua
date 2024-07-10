--[[
Automatyrant Reactor Gears Dragon
Automatiranno Drago Reattore di Ingranaggi
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--"Automatyrant Clockwork Dragon" + 2 Machine monsters
	aux.AddFusionProcCodeFun(c,CARD_AUTOMATYRANT_CLOCKWORK_DRAGON,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),2,true,true)
	--Contact Fusion
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	--Summoning condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.fuslimit)
	c:RegisterEffect(e0)
	--[[If this card is Fusion Summoned: You can target up to 3 Equip Spells or Union monsters in your GY; equip those targets to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.FusionSummonedCond,nil,s.eqtg,s.eqop)
	c:RegisterEffect(e1)
	--[[If this card battles an opponent's monster: You can send 1 Equip Card you control to the GY; that monster loses 800 ATK,
	and if it does, this card gains 800 ATK. These changes last until the end of the Damage Step.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:HOPT()
	e2:SetFunctions(
		s.atkcon,
		aux.ToGraveCost(s.cfilter,LOCATION_SZONE),
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
	--[[This card can make an additional attack during each Battle Phase, up to the number of Equip Cards you control.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(s.extraatkval)
	c:RegisterEffect(e3)
end
s.has_text_type=TYPE_UNION

--E0
function s.fuslimit(e,se,sp,st)
	return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end

--E1
function s.tgcheck(c)
	return c:IsMonster(TYPE_UNION) or c:IsSpell(TYPE_EQUIP)
end
function s.unionfilter(c,tc,tp,e)
	return c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
		and ((c:IsMonster(TYPE_UNION) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc))
		or (c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(tc)))
end
function s.oldunion(c)
	return c.old_union
end
function s.unionchk(g,e,tp,mg,c)
	return g:FilterCount(Card.IsType,nil,TYPE_UNION)<=1 or g:FilterCount(s.oldunion,nil)==0, c and c.old_union and g:FilterCount(Card.IsType,c,TYPE_UNION)>0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.unionfilter(chkc,c,tp,e) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.Group(s.unionfilter,tp,LOCATION_GRAVE,0,nil,c,tp,e)
	if chk==0 then
		return ft>0 and #g>0
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,math.min(3,ft),s.unionchk,1,tp,HINTMSG_TARGET,s.unionchk)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_EQUIP)
	Duel.SetCardOperationInfo(tg,CATEGORY_LEAVE_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.tgcheck,nil)
	if #g==0 or not c:IsRelateToChain() or not c:IsFaceup() then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>0 and ft<#g then
		Duel.HintMessage(tp,HINTMSG_EQUIP)
		g=g:Select(tp,ft,ft,nil)
		Duel.HintSelection(g)
	end
	for tc in aux.Next(g) do
		if Duel.Equip(tp,tc,c,true,true) then
			if tc:IsOriginalType(TYPE_UNION) then
				aux.SetUnionState(tc)
			end
		end
	end
	Duel.EquipComplete()
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	Duel.SetTargetCard(bc)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),LOCATION_MZONE,800)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,bc,1,bc:GetControler(),LOCATION_MZONE,-800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() and bc:IsRelateToChain() and bc:IsFaceup() then
		local e1=bc:UpdateATK(-800,RESET_PHASE|PHASE_DAMAGE,c,nil,nil,nil,nil,true)
		if bc:RegisterEffect(e1) and not bc:IsImmuneToEffect(e1) and not bc:IsHasEffect(EFFECT_REVERSE_UPDATE) and c:IsRelateToBattle() and c:IsRelateToChain() and c:IsFaceup() then
			c:UpdateATK(800,RESET_PHASE|PHASE_DAMAGE,{c,true})
		end
	end
end

--E3
function s.cfilter(c)
	return c:GetEquipTarget()~=nil
end
function s.extraatkval(e,c)
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
end