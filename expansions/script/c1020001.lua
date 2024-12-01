--[[
CODEMAN: Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	--[[If your opponent Special Summons a monster(s) with an original ATK higher than the ATK of a monster(s) you control (except during the Damage Step): You can target 1 monster you control with
	the lowest ATK and 1 of those Summoned monsters; send both targets to the GY and Special Summon this card from your hand or GY, then this card gains ATK equal to the difference between the ATK
	those targets had on the field. ]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.evfilter,id,LOCATION_HAND|LOCATION_GRAVE,nil,LOCATION_GRAVE)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+s.progressive_id)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[Once per turn: You can activate 1 of these effects.
	● Target 1 other monster you control; it gains ATK equal to the difference between its ATK and this card's ATK.
	● If you control another monster with ATK different from its original ATK (Quick Effect): You can double this card's ATK, and if you do, its ATK becomes equal to its original ATK during the End
	Phase.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetFunctions(nil,aux.InfoCost,s.atktg,s.atkop)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetRelevantBattleTimings()
	e3:SetFunctions(s.atkcon2,aux.InfoCost,s.atktg2,s.atkop2)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e3)
end
--E1
function s.evfilter(c,_,tp)
	if not c:IsFaceup() or not c:IsSummonPlayer(1-tp) then return false end
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return false end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return c:GetBaseAttack()>atk
end
function s.targetchk(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToGrave()
end
function s.gcheck(c,eg,tp)
	return eg:IsExists(s.zonechk,1,c,c,tp)
end
function s.zonechk(c2,c1,tp)
	return Duel.GetMZoneCount(tp,Group.FromCards(c1,c2))>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local ming=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMinGroup(Card.GetAttack):Filter(s.targetchk,nil,e)
	local g=eg:Clone():Filter(s.targetchk,nil,e)
	g:Merge(ming)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #eg>0 and ming:IsExists(s.gcheck,1,nil,eg,tp) end
	Duel.HintMessage(tp,HINTMSG_TOGRAVE)
	local tg1=ming:FilterSelect(tp,s.gcheck,1,1,nil,eg,tp)
	e:SetLabelObject(tg1:GetFirst())
	local tg2=eg:FilterSelect(tp,s.zonechk,1,1,tg1,tg1:GetFirst(),tp)
	tg1:Merge(tg2)
	Duel.SetTargetCard(tg1)
	Duel.SetCardOperationInfo(tg1,CATEGORY_TOGRAVE)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	local atk=math.abs(tg1:GetFirst():GetAttack()-tg1:GetNext():GetAttack())
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,atk)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	local g=Duel.GetTargetCards()
	if g:FilterCount(Card.IsAbleToGrave,nil)~=2 then return end
	local tc1=e:GetLabelObject()
	local ming=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMinGroup(Card.GetAttack)
	if not ming:IsContains(tc1) then return end
	local atk=math.abs(g:GetFirst():GetAttack()-g:GetNext():GetAttack())
	if Duel.SendtoGraveAndCheck(g,nil,REASON_EFFECT,2) and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsFaceup() then
		Duel.BreakEffect()
		if atk==0 then return end
		c:UpdateATK(atk,true,c)
	end
end

--E2
function s.atkfilter(c,atk)
	return c:IsFaceup() and math.abs(c:GetAttack()-atk)>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc,atk) and c~=chkc end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,c,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c,atk):GetFirst()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0,math.abs(tc:GetAttack()-atk))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and tc:IsRelateToChain() and tc:IsFaceup() then
		local atk=math.abs(c:GetAttack()-tc:GetAttack())
		if atk>0 then
			tc:UpdateATK(atk,true,{c,true})
		end
	end
end

--E3
function s.cfilter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and aux.ExceptOnDamageCalc()
end
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,-2,OPINFO_FLAG_DOUBLE)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local e1,_,_,diff=c:DoubleATK(true,c)
		if not c:IsImmuneToEffect(e1) then
			local eid=e:GetFieldID()
			c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,3))
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(id,4)
			e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE|PHASE_END)
			e3:SetCountLimit(1)
			e3:SetLabel(eid)
			e3:SetCondition(s.atkdowncon)
			e3:SetOperation(s.atkdown)
			e3:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.atkdowncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	if not c:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.atkdown(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ChangeATK(c:GetBaseAttack(),true,c)
end