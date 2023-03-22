--created by Zerry, coded by Lyris
--One With The Chaos
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--material
	aux.AddLinkProcedure(c,nil,2,2,s.gchk)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DRIVE))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(1192)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.gchk(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_DRIVE)
end
function s.filter(c,g,en,tp)
	return g:IsContains(c) and (c:IsLevelAbove(1) and (en:IsCanUpdateEnergy(c:GetLevel(),tp,REASON_EFFECT)
			or en:IsCanUpdateEnergy(-c:GetLevel(),tp,REASON_EFFECT)) or c:IsRankAbove(1)
		and (en:IsCanUpdateEnergy(c:GetRank(),tp,REASON_EFFECT)
			or en:IsCanUpdateEnergy(-c:GetRank(),tp,REASON_EFFECT))) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	local en=Duel.GetEngagedCard(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,lg,en,tp) end
	if chk==0 then return en and en:IsMonster()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,en,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg,en,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,er,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and c:GetLinkedGroup():IsContains(tc) then
		local en=Duel.GetEngagedCard(tp)
		local lv=tc:IsRankAbove(1) and tc:GetRank() or tc:IsLevelAbove(1) and tc:GetLevel()
		if not lv then return end
		local b1,b2=en:IsCanUpdateEnergy(lv,tp,REASON_EFFECT),en:IsCanUpdateEnergy(-lv,tp,REASON_EFFECT)
		local op=-aux.Option(id,tp,0,b1,b2)
		if op==0 then op=op+1 end
		en:UpdateEnergy(lv*op,tp,REASON_EFFECT,true,c)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
