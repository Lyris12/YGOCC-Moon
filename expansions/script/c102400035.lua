--created & coded by Lyris, art at https://st2.depositphotos.com/1007989/5894/i/950/depositphotos_58949825-stock-photo-kids-stargazing-through-telescope.jpg
--「S・VINE」スターゲイザー
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	local g=Duel.GetDecktopGroup(tp,c:GetLevel())
	return c:IsSetCard(0x85a) and c:IsLevelAbove(1) and g:FilterCount(Card.IsAbleToRemove,nil)==#g
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel())
	Duel.Release(g,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetDecktopGroup(tp,e:GetLabel())
	if #rg>rg:FilterCount(Card.IsAbleToRemove,nil) then return end
	Duel.ConfirmDecktop(tp,e:GetLabel())
	local g=Duel.GetDecktopGroup(tp,e:GetLabel())
	local sg=g:Filter(Card.IsSetCard,nil,0x285b)
	if #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_REVEAL)
	end
	Duel.SortDecktop(tp,tp,e:GetLabel()-#sg)
	for i=1,e:GetLabel()-#sg do
		local mg=Duel.GetDecktopGroup(tp,1)
		Duel.MoveSequence(mg:GetFirst(),1)
	end
end
