--Shared Effects
Marionightte=Marionightte or {}
Marionightte.ID = 28940260
function Marionightte.Is(c) return (aux.IsCodeListed(c,Marionightte.ID) or c:IsCode(Marionightte.ID)) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)) end

function Marionightte.Induct(c,val)
	aux.AddCodeList(c,Marionightte.ID)
	if not marionightte_global_counter then
		marionightte_global_counter=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler():IsCode(Marionightte.ID) end)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(rp,Marionightte.ID,0,0,0) end)
		Duel.RegisterEffect(ge1,0)
	end
	if val>0 then
		--Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,Marionightte.counterfilter)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(Marionightte.AttackValue(val))
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		return e1,e2
	end
	return nil
end
--[[function Marionightte.counterfilter(c)
	return c:GetReasonCard()==nil or c:GetReasonCard():GetCode()~=Marionightte.ID
end]]
function Marionightte.AttackValue(val)
	return function(e,c)
		return Marionightte.RewardCount(e:GetHandlerPlayer())*val
	end
end

function Marionightte.RewardCon(val)
	return function(e,tp)
			return Marionightte.RewardCount(tp)>=val
		end
end
function Marionightte.RewardCount(tp)
	return Duel.GetFlagEffect(tp,Marionightte.ID) --Duel.GetCustomActivityCount(Marionightte.ID,tp,ACTIVITY_SPSUMMON)
end


function Marionightte.IsRaceInText(c,race)
	return c.has_text_race and race&c.has_text_race==race
end
