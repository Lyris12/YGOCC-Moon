--Peach Beach Splash Party
function c69013.initial_effect(c)
local  e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69013.sptg)
	e1:SetOperation(c69013.spop)
	e1:SetCountLimit(1,69013+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function c69013.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6969) and c:IsPublic()
		and Card.IsCanBeSpecialSummoned(c,e,0,tp,false,false)
end
function c69013.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rev=Duel.GetMatchingGroup(c69013.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return #rev>2 end
	rev:KeepAlive()
	e:SetLabelObject(rev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,#rev*500)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rev,#rev,tp,LOCATION_HAND)
end
function c69013.spop(e,tp,eg,ep,ev,re,r,rp)
	local rev=e:GetLabelObject():Filter(Card.IsRelateToEffect,nil,e)
	if #rev>0 then
			local ct=Duel.SpecialSummon(rev,0,tp,tp,false,false,POS_FACEUP)
			if ct>0 then Duel.BreakEffect() Duel.Recover(tp,ct*500,REASON_EFFECT) end
		end
	end
end
