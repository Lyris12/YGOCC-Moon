--SKILL: Annulla Abilità
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Skill Negation
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EVENT_ADJUST)
	SKILL:SetCondition(aux.skillcon)
	SKILL:SetOperation(cid.skillop)
	c:RegisterEffect(SKILL)
end
--filters
function cid.flagcheck(c)
	return c:IsType(TYPE_SKILL) and c:GetFlagEffect(id)<=0
end
--Afterblow
function cid.skillop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetControler()
	if not c:IsLocation(LOCATION_EXTRA) or not c:IsControler(p) then return end
	local g=Duel.GetMatchingGroup(cid.flagcheck,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_OVERLAY+LOCATION_DECK,nil)
	if g:GetCount()<=0 then return end
	for rc in aux.Next(g) do
		if rc:GetFlagEffect(id)<=0 then
			rc:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+id,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			local m=_G["c"..rc:GetOriginalCode()]
			if not m then return false end
			local egroup=m.default_call_table
			if egroup~=nil then
				for cte=1,#egroup do
					local ce=egroup[cte]
					if ce:GetType()==TYPE_FIELD+TYPE_CONTINUOUS then
						local op=ce:GetOperation()
						if op then
							ce:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
												if Duel.GetLP(1-e:GetHandlerPlayer())<=1000 and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_HAND,0)>Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_HAND,0) and Duel.IsPlayerCanDraw(1-e:GetHandlerPlayer(),2) then
													if Duel.SelectYesNo(1-e:GetHandlerPlayer(),aux.Stringid(id,0)) then
														Duel.Hint(HINT_CARD,e:GetHandlerPlayer(),id)
														Duel.Draw(1-e:GetHandlerPlayer(),2,REASON_RULE+1)
														return
													end
												end
												op(e,tp,eg,ep,ev,re,r,rp)
											end)
						end
					elseif ce:GetCode()==EFFECT_SPSUMMON_PROC_G then
						local op=ce:GetOperation()
						if op then
							ce:SetOperation(function (e,tp,eg,ep,ev,re,r,rp,c)
												if Duel.GetLP(1-e:GetHandlerPlayer())<=1000 and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_HAND,0)>Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_HAND,0) and Duel.IsPlayerCanDraw(1-e:GetHandlerPlayer(),2) then
													if Duel.SelectYesNo(1-e:GetHandlerPlayer(),aux.Stringid(id,0)) then
														Duel.Hint(HINT_CARD,e:GetHandlerPlayer(),id)
														Duel.Draw(1-e:GetHandlerPlayer(),2,REASON_RULE+1)
														return
													end
												end
												op(e,tp,eg,ep,ev,re,r,rp,c)
											end)
						end
					end
				end
			end
		end
	end
end