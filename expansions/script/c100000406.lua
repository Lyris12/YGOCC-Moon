--[[
Unknown HERO Masquerade
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_UNKNOWN_HERO_CALLING)
	--During the Standby Phase (Quick Effect): You can target 1 monster in your opponent's GY; until the end of this turn, this card's name becomes that monster's original name, also replace this effect with that monster's original effects.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetFunctions(aux.StandbyPhaseCond(),nil,s.copytg,s.copyop)
	c:RegisterEffect(e1)
	--During damage calculation, if this card attacks an opponent's monster: You can send 1 Level 5 or higher "HERO" monster from your Deck to the GY; this card gains ATK equal to the ATK of that sent monster during that damage calculation only.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetLabelObject(e1)
	e2:HOPT()
	e2:SetFunctions(s.atkcon,aux.DummyCost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	--If this card is used as Fusion or Synchro Material for the Summon of a "HERO" monster: That monster gains this card's other effects.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetLabelObject(e2)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
--E1
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsMonster() end
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and Duel.IsExistingTarget(Card.IsMonster,tp,0,LOCATION_GRAVE,1,nil) end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsMonster,tp,0,LOCATION_GRAVE,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToChain() and c:IsFaceup() and tc:IsRelateToChain() and tc:IsMonster() then
		local code=tc:GetOriginalCodeRule()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		c:CopyEffect(tc:GetOriginalCode(),RESETS_STANDARD_PHASE_END,1)
	end
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetAttacker()==c and c:IsRelateToBattle() and bc and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
function s.tgcfilter(c)
	return c:IsSetCard(ARCHE_HERO) and c:IsLevelAbove(5) and c:IsAttackAbove(1) and c:IsAbleToGraveAsCost()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() and Duel.IsExists(false,s.tgcfilter,tp,LOCATION_DECK,0,1,nil) end
	local tc=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgcfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local atk=tc:GetAttack()
	Duel.SetTargetParam(atk)
	Duel.SendtoGrave(tc,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local atk=Duel.GetTargetParam()
		c:UpdateATK(atk,RESET_PHASE|PHASE_DAMAGE_CAL,c)
	end
end

--E3
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_FUSION|REASON_SYNCHRO)>0 and e:GetHandler():GetReasonCard():IsSetCard(ARCHE_HERO)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetReasonCard())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if rc:IsRelateToChain() and rc:IsFaceup() then
		rc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		local e2=e:GetLabelObject()
		local e1=e2:GetLabelObject()
		local reg1,reg2=e1:Clone(),e2:Clone()
		reg1:SetReset(RESET_EVENT|RESETS_STANDARD)
		reg2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(reg1,true)
		rc:RegisterEffect(reg2,true)
		if not rc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			rc:RegisterEffect(e2,true)
		end
	end
end