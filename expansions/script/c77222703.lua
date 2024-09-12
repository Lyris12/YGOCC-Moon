--Anbionic Mixup
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 face-up monster you control; destroy it, and if you do, apply 1 this effect, depending on its Vibe on the field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	local op1=Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local op2=Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	return c:IsFaceup() and ((c:IsPositive() and op2 and Duel.GetMZoneCount(tp,c)>0))
	or (c:IsNegative() and op1 and Duel.GetMZoneCount(tp,c)>0)
	or (c:IsNeutral() and op1 and op2 and Duel.GetMZoneCount(tp,c)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if(g:GetFirst():IsNeutral()) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local otc=e:GetLabelObject()
	local c=e:GetHandler()
	local op1=Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local op2=Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local tc=Duel.GetFirstTarget()
	--also you cannot Special Summon monsters from your Extra Deck for the rest of this turn, except "Anbionic" monsters.
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	Duel.RegisterEffect(e3,tp)
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		if(otc:IsNeutral() and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and op1 and op2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
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
			local tk2=Duel.CreateToken(tp,177222704)
			if(Duel.SpecialSummonStep(tk2,0,tp,tp,false,false,POS_FACEUP)) then
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
				tk2:RegisterEffect(e2)
				tk2:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
			end
			Duel.SpecialSummonComplete()
		elseif(otc:IsNegative() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and op1) then
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
		elseif(otc:IsPositive() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and op2) then
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
		end
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(0xe57) and c:IsLocation(LOCATION_EXTRA)
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