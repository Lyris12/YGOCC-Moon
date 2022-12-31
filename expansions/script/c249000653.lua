--Guardian-Summon Weaponmaster
function c249000653.initial_effect(c)
	c:SetUniqueOnField(1,0,249000652)
	c:EnableReviveLimit()
	--dice
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c249000653.operation)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)
end
function c249000653.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local d=Duel.TossDice(tp,1)
		if d==3 or d==4 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(e:GetHandler():GetBaseAttack())
			e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END,2)
			e:GetHandler():RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e2:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END,2)
			e:GetHandler():RegisterEffect(e2)
		elseif d==5 or d==6 then
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
				Duel.Damage(1-tp,tc:GetPreviousAttackOnField(),REASON_EFFECT)
			end
		else
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
		local d=Duel.TossDice(tp,1)
		if d==3 or d==4 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(e:GetHandler():GetBaseAttack())
			e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END,2)
			e:GetHandler():RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e2:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END,2)
			e:GetHandler():RegisterEffect(e2)
		elseif d==5 or d==6 then
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
				Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		else
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
