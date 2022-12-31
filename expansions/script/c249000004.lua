--Xyz-Hunter
function c249000004.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c249000004.tgcondition)
	e2:SetTarget(c249000004.tgtarget)
	e2:SetOperation(c249000004.tgoperation)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,249000004)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c249000004.cost)
	e3:SetTarget(c249000004.target)
	e3:SetOperation(c249000004.operation)
	c:RegisterEffect(e3)
	--damage reduce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c249000004.rdcon)
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)
end

function c249000004.tgcondition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end
function c249000004.tgtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
function c249000004.tgoperation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_EXTRA,nil)
	Duel.ConfirmCards(tp,tg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=tg:Select(tp,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c249000004.cfilter2(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
function c249000004.cfilter3(c)
	return c:IsSetCard(0x4073) and c:IsAbleToRemoveAsCost()
end
function c249000004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000004.cfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		and Duel.IsExistingMatchingCard(c249000004.cfilter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,c249000004.cfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	e:SetLabel(g1:GetFirst():GetRank())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,c249000004.cfilter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
function c249000004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000004.operation(e,tp,eg,ep,ev,re,r,rp)
	local rk=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ac=Duel.AnnounceCard(tp,TYPE_XYZ)
	sc=Duel.CreateToken(tp,ac)
	Duel.SendtoDeck(sc,nil,0,REASON_RULE)
	if sc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetLabel(ac)
		e1:SetTarget(c249000004.splimit)
		if sc:GetRank() >=4 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0) >= math.abs(rk-sc:GetRank()) and Duel.GetLocationCountFromEx(tp)>0 and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
			and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0 and Duel.SelectYesNo(tp,2) then
			if rk~=sc:GetRank() then
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,math.abs(rk-sc:GetRank()),math.abs(rk-sc:GetRank()),nil)
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			local mg=Group.CreateGroup()
			local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
			if tc2 then
				mg:AddCard(tc2)
				Duel.Overlay(sc,tc2)
			end
			tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
			if tc2 then
				mg:AddCard(tc2)
				Duel.Overlay(sc,tc2)
			end
			if mg:GetCount() > 0 then sc:SetMaterial(mg) end
			sc:CompleteProcedure()
		end
	end
end
function c249000004.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (not se:GetHandler():IsCode(249000004)) and c:IsCode(e:GetLabel())
end
function c249000004.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end