--Cold Front
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30


local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.a_tg)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
end

function s.a_fil(c)
	return c:GetCounter(COUNTER_ICE)>0
end
function s.a_sfil(c,e,tp)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.a_fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.a_fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.a_fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 and
			Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
			Duel.IsExistingMatchingCard(s.a_sfil,tp,LOCATION_DECK,0,1,nil,e,tp) and
			Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			Duel.Hint(HINT_SELECTMSG,tp,HINMSG_SPSUMMON)
			local tc=Duel.SelectMatchingCard(tp,s.a_sfil,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
			if tc then
				Duel.BreakEffect()
				if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
					local c=e:GetHandler()
					local ct=Duel.GetNextPhaseCount(PHASE_END,tp)
					local fid=c:GetFieldID()
					tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,ct,fid,aux.Stringid(id,2))
					local e1=Effect.CreateEffect(c)
					e1:SetOwnerPlayer(tp)
					e1:SetDescription(aux.Stringid(id,1))
					e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE|PHASE_END)
					e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					e1:SetCountLimit(1)
					e1:SetLabel(fid)
					e1:SetLabelObject(tc)
					e1:SetCondition(s.a_dcd)
					e1:SetOperation(s.a_dop)
					if ct==2 then
						e1:SetValue(Duel.GetTurnCount())
					else
						e1:SetValue(0)
					end
					e1:SetReset(RESET_PHASE|PHASE_END,ct)
					Duel.RegisterEffect(e1,tp)
					
					if Duel.PlayerHasFlagEffect(tp,id) then
						Duel.UpdateFlagEffectLabel(tp,id)
					else
						Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,ct,1)
					end
				end
			end
		end
	end
end

function s.a_dcd(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffect(id)~=0 and tc:GetFlagEffectLabel(id)==e:GetLabel() then return true end
	e:Reset()
	return false
end
function s.a_dop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.GetFlagEffectLabel(tp,id)>1 then
		Duel.HintSelection(Group.FromCards(tc))
		if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			e:SetCountLimit(1)
			return
		end
	end
	Duel.UpdateFlagEffectLabel(tp,id,-1)
	Duel.Destroy(tc,REASON_EFFECT,LOCATION_GRAVE,tc:GetControler())
end