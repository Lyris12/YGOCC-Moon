--Drum Angel of Trumpeter
function c500317851.initial_effect(c)
aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,2,c500317851.filter1,1)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500317851,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	--e1:SetCountLimit(1,500317851)
	e1:SetCondition(c500317851.con)
	e1:SetTarget(c500317851.tg)
	e1:SetOperation(c500317851.op)
	c:RegisterEffect(e1)
	--maintain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c500317851.mtcon)
	e4:SetOperation(c500317851.mtop)
	c:RegisterEffect(e4)
	  local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SET_BASE_ATTACK)
	e5:SetValue(c500317851.val)
	c:RegisterEffect(e5)
	
		--Atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetOperation(c500317851.regop)
	c:RegisterEffect(e6)
end

function c500317851.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function c500317851.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_FIEND) 
end
function c500317851.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c500317851.hspfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) 
end
function c500317851.checkdiscard(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND)
end
function c500317851.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,60,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		local op=Duel.GetOperatedGroup()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local fcount=op:FilterCount(c500317851.checkdiscard,nil)
			if fcount>0 then
			 --   local e1=Effect.CreateEffect(c)
			 --   e1:SetType(EFFECT_TYPE_SINGLE)
			 --   e1:SetCode(EFFECT_SET_BASE_ATTACK)
			  --  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			   -- e1:SetValue(fcount*200)
				--c:RegisterEffect(e1)
				c:AddEC(fcount)

					local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500317851,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,500317851,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
function c500317851.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c500317851.mtop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.IsCanRemoveEC(tp,3,REASON_COST)  then
		Duel.RemoveEC(tp,3,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function c500317851.val(e,c)
	local ct=e:GetHandler():GetFlagEffectLabel(500317851)
	if not ct then return 0 end
	return ct
end
function c500317851.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_SPECIAL+388) then
		local ct=c:GetMaterialCount()
		c:RegisterFlagEffect(500317851,RESET_EVENT+RESETS_STANDARD,0,0,ct*800)
	end
end

