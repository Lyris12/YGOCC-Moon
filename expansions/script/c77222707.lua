--Anbionic Companion Hound
local s,id,o=GetID()
function s.initial_effect(c)
	--Equip only to an "Anbionic" monster, or a Bigbang Monster.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--The equipped monster cannot be Tributed, also control of it cannot switch.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e5)
	--During your Main Phase: You can Special Summon 1 "Spinup Token" (Thunder/LIGHT/Level 1/1000 ATK/0 DEF) or 1 "Spindown Token" (Thunder/LIGHT/Level 1/0 ATK/1000 DEF), with the same Vibe as the equipped monster.
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,{id,0})
	e6:SetTarget(s.tktg)
	e6:SetOperation(s.tkop)
	c:RegisterEffect(e6)
	--If a monster(s) you control that you can place a Charge Counter on is sent to your GY by an opponent's card, while this card is in your GY:
	--You can target 1 of them; Special Summon it, then equip it with this card, and if you do, place 1 Charge Counter on that monster.
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.eqcon)
	e7:SetTarget(s.eqtg)
	e7:SetOperation(s.eqop)
	c:RegisterEffect(e7)
end
function s.eqlimit(e,c)
	return c:IsSetCard(0xe57) or c:IsType(TYPE_BIGBANG)
end
function s.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0xe57) or c:IsType(TYPE_BIGBANG))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local op1=Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local op2=Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local etg=e:GetHandler():GetEquipTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ((etg:IsPositive() and op1) or (etg:IsNegative() and op2)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op1=Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local op2=Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local etg=e:GetHandler():GetEquipTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and etg:IsNegative() and op2 then
		local tk=Duel.CreateToken(tp,177222704)
		if(Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DESTROYED)
			e1:SetCondition(s.drawcon)
			e1:SetOperation(s.drawop)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_DESTROY)
			e2:SetLabelObject(e1)
			e2:SetOperation(s.checkop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tk:RegisterEffect(e2)
			tk:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
		Duel.SpecialSummonComplete()
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and etg:IsPositive() and op1 then
		local tk=Duel.CreateToken(tp,177222703)
		if(Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DESTROYED)
			e1:SetCondition(s.drawcon)
			e1:SetOperation(s.drawop)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_DESTROY)
			e2:SetLabelObject(e1)
			e2:SetOperation(s.checkop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tk:RegisterEffect(e2)
			tk:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
		Duel.SpecialSummonComplete()
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:SetLabel(1)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end
function s.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:GetReasonPlayer()==1-tp
		and c:IsCanHaveCounter(0x157) and Duel.IsCanAddCounter(tp,0x157,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsContains(c)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spfilter,1,nil,e,tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.spfilter,nil,e,tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter2(chkc,e,tp,g) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,g) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local ec=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		if(Duel.Equip(tp,c,tc)) then
			tc:AddCounter(0x157,1)
		end
	end
end