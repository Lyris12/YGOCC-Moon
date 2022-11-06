--Divinità Bushido Drago Ignis
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x4b0),4,3,nil,nil,99)
	c:MustFirstBeSummoned(SUMMON_TYPE_XYZ)
	--protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DD,true,
		aux.XyzSummonedCond,
		nil,
		aux.TargetUpToTheNumberOfCards(Card.IsSpellTrapOnField,0,LOCATION_ONFIELD,1,nil,s.cfilter,LOCATION_MZONE,0,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation(SUBJECT_THEM)
	)
	--extra attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetCondition(aux.HasXyzMaterialCond)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--negate attack
	c:DeclaredAttackFieldTrigger(nil,false,1,CATEGORY_ATKCHANGE,nil,nil,true,
		nil,
		aux.DetachSelfCost(),
		s.negtg,
		aux.CreateOperation(
			aux.NegateAttackOperation,
			CONJUNCTION_AND_IF_YOU_DO,
			aux.UpdateATKOperation(SUBJECT_THIS_CARD,500,true)
		)
	)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b0)
end

function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount()
end

function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b0) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,500)
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,c) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end