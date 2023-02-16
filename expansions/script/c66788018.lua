--Taglioimprovviso
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:CannotBeSet()
	c:Activate(0,CATEGORY_DESTROY+CATEGORY_ATKCHANGE,EFFECT_FLAG_DAMAGE_STEP,false,{1,0},s.condition,nil,s.target,s.operation,aux.LocationGroupCond(s.hf,LOCATION_MZONE,0,1))
end
function s.hf(c)
	return c:IsFaceup() and c:IsMonster() and c:HasLowestATK()
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.condition(e,tp)
	return aux.LocationGroupCond(aux.Faceup(Card.IsMonster),LOCATION_MZONE,0,1)(e,tp) and aux.CompareLocationGroupCond(1,Card.MonsterOrFacedown)(e,tp)
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=aux.DestroyTarget(aux.Faceup(Card.IsMonster),LOCATION_MZONE,LOCATION_MZONE,1)(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk~=0 then
		local g=Duel.Group(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
		end
	end
	return res
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,aux.Faceup(Card.IsMonster),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg)
		local dc=dg:GetFirst()
		local atk=dc:GetAttack()
		local thencheck=dc:HasLowestATK()
		if Duel.Destroy(dc,REASON_EFFECT)>0 then
			local atkg=Duel.Group(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			if #atkg>0 then
				local check=false
				for tc in aux.Next(atkg) do
					local preatk=tc:GetAttack()
					tc:ChangeATK(atk,true,e:GetHandler())
					if not check and tc:GetAttack()~=preatk and tc:GetAttack()==atk then
						check=true
					end
				end
				if check and thencheck and dc:IsMonster() and (dc:IsLocation(LOCATION_GB) or dc:IsInExtra(true)) then
					Duel.Negate(dc,e,RESET_PHASE+PHASE_END,true)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
					e1:SetTarget(s.distg)
					e1:SetLabel(atk)
					e1:SetReset(RESET_PHASE+PHASE_END)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
end
function s.distg(e,c)
	local atk=e:GetLabel()
	return c:IsAttackBelow(atk)
end