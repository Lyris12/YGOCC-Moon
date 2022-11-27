-- Radiant-Summon - Volcannic Beast
function c249000110.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16898077,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c249000110.target)
	e2:SetOperation(c249000110.operation)
	c:RegisterEffect(e2)
end
function c249000110.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp):GetCount()>0 end
	local g=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	local mg,matk=g:GetMaxGroup(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if matk > 0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.ceil(matk/2))
	end
end
function c249000110.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
		local mg,matk=g:GetMaxGroup(Card.GetPreviousAttackOnField)
		if matk>0 then
			Duel.Damage(1-tp,math.ceil(matk/2),REASON_EFFECT)
		end
	end
end